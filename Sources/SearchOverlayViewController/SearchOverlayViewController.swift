import UIKit

@available(iOS 13.0, *)
public class SearchOverlayViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
  private let configuration: SearchOverlayViewConfiguration
  private let searcher: ((String?, @escaping ((Bool) -> Void)) -> Void)
  private let stackView = UIStackView()
  private let tableView = UITableView()
  private let textFieldStackView = UIStackView()
  private let textField = UITextField()
  private let textFieldStackViewTopInset: CGFloat = 10
  private let stackViewSpacing: CGFloat = 10
  private var tableViewHeightConstraint: NSLayoutConstraint!
  private var stackViewBottomConstraint: NSLayoutConstraint!
  private var maximumHeight: CGFloat = 0
  weak var tableViewDelegate: UITableViewDelegate?
  weak var tableViewDataSource: UITableViewDataSource?
  weak var modalPresenterDelegate: SearchOverlayPresenterDelegate?

  public init(configuration: SearchOverlayViewConfiguration, searcher: @escaping ((String?, @escaping ((Bool) -> Void)) -> Void)) {
    self.configuration = configuration
    self.searcher = searcher
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    stackView.axis = .vertical
    stackView.spacing = stackViewSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    textFieldStackView.spacing = 5
    textFieldStackView.alignment = .top
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "magnifyingglass")
    imageView.tintColor = .label
    imageView.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Search"
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .words
    textField.delegate = self
    textField.becomeFirstResponder()
    textFieldStackView.addArrangedSubview(imageView)
    textFieldStackView.addArrangedSubview(textField)
    stackView.addArrangedSubview(textFieldStackView)
    setTableView()
    tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    stackViewBottomConstraint = view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10)
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      imageView.heightAnchor.constraint(equalToConstant: 25),
      imageView.widthAnchor.constraint(equalToConstant: 25),
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: textFieldStackViewTopInset),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 10),
      stackViewBottomConstraint,
      tableViewHeightConstraint,
    ])
  }

  public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate { _ in
      self.layoutTableView()
    }
  }

  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layoutTableView()
  }

  private func setTableView() {
    switch configuration.cell {
    case .cellWithClass(let className):
      tableView.register(className, forCellReuseIdentifier: "\(className)")
    case .cellWithNib(let nibName):
      tableView.register(UINib(nibName: "\(nibName)", bundle: nil), forCellReuseIdentifier: "\(nibName)")
    }
    tableView.delegate = tableViewDelegate
    tableView.dataSource = tableViewDataSource
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
  }

  func setMaximumHeight(_ maximumHeight: CGFloat) {
    self.maximumHeight = maximumHeight
  }

  // MARK: - UITextFieldDelegate

  public func textFieldDidChangeSelection(_ textField: UITextField) {
    if textField.text?.isEmpty == false {
      stackView.addArrangedSubview(tableView)
      stackViewBottomConstraint?.constant = 0
      searcher(textField.text) { [weak self] hasSearchResults in
        self?.tableView.reloadData()
        self?.tableView.performBatchUpdates(nil) { _ in
          if hasSearchResults {
            self?.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
          }
          self?.layoutTableView()
        }
      }
    } else {
      stackViewBottomConstraint?.constant = textFieldStackViewTopInset
      tableView.removeFromSuperview()
      modalPresenterDelegate?.willResizePresentedViewController(self)
    }
  }

  private func layoutTableView() {
    let textFieldStackViewHeight = textFieldStackView.frame.height + textFieldStackViewTopInset + stackViewSpacing
    let maximumTableViewHeight = maximumHeight - textFieldStackViewHeight
    tableViewHeightConstraint?.constant = min(tableView.contentSize.height, maximumTableViewHeight)
    modalPresenterDelegate?.willResizePresentedViewController(self)
  }

  // MARK: - UIScrollViewDelegate

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    textField.resignFirstResponder()
  }
}
