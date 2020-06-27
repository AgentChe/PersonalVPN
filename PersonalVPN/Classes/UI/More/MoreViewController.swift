//
// Created by Anton Serov on 26.10.2019.
// Copyright (c) 2019 org. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class MoreViewController: UIViewController {
    var viewModel: MoreViewModel!

    private let disposeBag = DisposeBag()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 50
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont(name: "Poppins-SemiBold", size: 34.0)
        label.text = "Settings"
        return label
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 42).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        view.addSubview(tableView)
        view.backgroundColor = .clear
        view.addSubview(activityIndicator)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.layer.cornerRadius = 20.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreCell")
        tableView.delegate = self
        viewModel
            .items
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "MoreCell", cellType: UITableViewCell.self)) { [weak self] (_, viewModel, cell) in
                self?.setupCell(cell, viewModel: viewModel)
            }
            .disposed(by: disposeBag)
        
        tableView
            .rx
            .modelSelected(ItemViewModel.self)
            .do(onNext: { [weak self] item in
                self?.viewModel.handleItem.accept(item)
            })
            .filter { $0.kind == .restorePurchases }
            .do(onNext: { [weak self] _ in
                self?.activityIndicator.startAnimating()
            })
            .flatMapLatest { _ in
                PurchaseService.paymentValidate()
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] _ in
                self?.activityIndicator.stopAnimating()
            })
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

    private func setupCell(_ cell: UITableViewCell, viewModel: ItemViewModel) {
        if let imageName = viewModel.imageName {
            cell.imageView?.image = UIImage(named: imageName)
        }
        cell.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 17.0)
        cell.accessoryView = UIImageView(image: UIImage(named: "arrow"))
        cell.textLabel?.text = viewModel.title
    }
}

extension MoreViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension MoreViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        MorePresentationController(presentedViewController: presented, presenting: presenting, containerHeight: 300)
    }
}

class MorePresentationController: DimmedBackgroundPresentationController {}
