import Foundation
import UIKit

class MainView: UIView {
    var startButton: UIButton!
    var circleImage: UIImageView!
    var circleShadowImage: UIImageView!

    var received: String? = nil {
        didSet {
            guard let r = received else {
                dataStack.isHidden = true
                return
            }
            dataStack.isHidden = false
            dataLabel.text = r
        }
    }

    var connectedDate: String? = nil {
        didSet {
            guard let c = connectedDate else {
                timeStack.isHidden = true
                return
            }
            timeStack.isHidden = false
            timeLabel.text = c
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-SemiBold", size: 25)
        label.textColor = UIColor(red: 0.87, green: 0.85, blue: 0.87, alpha: 1)
        return label
    }()

    private lazy var timeCaptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.87, green: 0.85, blue: 0.87, alpha: 1)
        label.font = UIFont(name: "Poppins-Regular", size: 17)
        label.text = "time"
        return label
    }()

    private lazy var dataLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Poppins-SemiBold", size: 25)
        label.textColor = UIColor(red: 0.87, green: 0.85, blue: 0.87, alpha: 1)
        return label
    }()

    private lazy var dataCaptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.87, green: 0.85, blue: 0.87, alpha: 1)
        label.font = UIFont(name: "Poppins-Regular", size: 17)
        label.text = "mb traffic"
        return label
    }()

    private lazy var timeStack: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [timeLabel, timeCaptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.isHidden = true
        return stack
    }()

    private lazy var dataStack: UIStackView = {
        var stack = UIStackView(arrangedSubviews: [dataLabel, dataCaptionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.isHidden = true
        return stack
    }()

    init() {
        super.init(frame: .zero)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    func showInfo() {
        timeStack.isHidden = false
        dataStack.isHidden = false
    }

    func hideInfo() {
        timeStack.isHidden = true
        dataStack.isHidden = true
    }

    private func initialize() {
        startButton = UIButton(type: .system)
        circleImage = UIImageView(image: UIImage(named: "sphere"))
        circleShadowImage = UIImageView(image:UIImage(named: "shadow"))
        startButton.translatesAutoresizingMaskIntoConstraints = false
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        circleShadowImage.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Connect", for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 28)
        startButton.titleLabel?.adjustsFontSizeToFitWidth = true
        startButton.setTitleColor(.white, for: .normal)
        backgroundColor = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 1)
        addSubview(circleImage)
        addSubview(circleShadowImage)
        addSubview(startButton)
        addSubview(dataStack)
        addSubview(timeStack)
        setupConstraints()
    }

    private func setupConstraints() {
        startButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        circleImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circleImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        circleShadowImage.centerXAnchor.constraint(equalTo: circleImage.centerXAnchor).isActive = true
        circleShadowImage.centerYAnchor.constraint(equalTo: circleImage.centerYAnchor, constant: -130).isActive = true


        timeStack.leadingAnchor.constraint(equalTo: circleImage.leadingAnchor).isActive = true
        timeStack.topAnchor.constraint(equalTo: circleImage.bottomAnchor, constant: 20).isActive = true
        timeStack.widthAnchor.constraint(equalToConstant: 90).isActive = true


        dataStack.trailingAnchor.constraint(equalTo: circleImage.trailingAnchor).isActive = true
        dataStack.topAnchor.constraint(equalTo: circleImage.bottomAnchor, constant: 20).isActive = true
        dataStack.widthAnchor.constraint(equalToConstant: 90).isActive = true
    }
}
