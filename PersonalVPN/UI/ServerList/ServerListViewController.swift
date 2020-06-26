import Foundation
import UIKit
import RxSwift

class VpnViewCell: UITableViewCell {
    var viewModel: ServerViewModel?

    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "oval"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(selectedImageView)
        selectedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18.0).isActive = true
        selectedImageView.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor).isActive = true
        indentationWidth = 16
        indentationLevel = 1
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectedImageView.isHidden = !selected
        textLabel?.textColor = selected ? .black : UIColor(hue: 0.67, saturation: 0.02, brightness: 0.57, alpha: 1.0)
    }

    func setup() {
        textLabel?.text = viewModel?.title
        setSelected(viewModel?.selected ?? false, animated: false)
    }
}

class ServerListViewController: UIViewController {
    var viewModel: ServerListViewModel!

    private let disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = 40
        view.estimatedRowHeight = 40
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: "Poppins-SemiBold", size: 13.0)
        label.text = "Change"
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: "Poppins-SemiBold", size: 28.0)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.81
        label.attributedText = NSMutableAttributedString(string: "Location", attributes: [NSAttributedString.Key.kern: -1.12, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return label
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 42).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -5).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        view.addSubview(tableView)
        view.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.layer.cornerRadius = 20.0
        tableView.register(VpnViewCell.self, forCellReuseIdentifier: "VpnCell")
        tableView.delegate = self
        viewModel
            .items.asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "VpnCell", cellType: VpnViewCell.self)) { [weak self] (_, viewModel, cell) in
                self?.setupCell(cell, viewModel: viewModel)
            }
            .disposed(by: disposeBag)
        tableView
            .rx
            .modelSelected(ServerViewModel.self)
            .bind(to: viewModel.selectServer)
            .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            var headerFrame = headerView.frame

            //Comparison necessary to avoid infinite loop
            if size != headerFrame.size {
                headerFrame.size = size
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
                headerView.layoutIfNeeded()
            }
        }
    }

    private func setupCell(_ cell: VpnViewCell, viewModel: ServerViewModel) {
        cell.viewModel = viewModel
    }
}

extension ServerListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? VpnViewCell {
            cell.setup()
        }
    }
}

extension ServerListViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let controller = DimmedBackgroundPresentationController(presentedViewController: presented, presenting: presenting, containerHeight: 240)
        controller.containerViewHeight = 250
        return controller
    }
}
