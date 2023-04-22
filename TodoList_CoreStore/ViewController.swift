import CoreStore
import UIKit

fileprivate let cellIdentifier = "Cell"

class ViewController: UIViewController {
    private lazy var addButton = UIBarButtonItem(
        title: "Add",
        style: .plain,
        target: self,
        action: #selector(addButtonHandler)
    )
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        return tableView
    }()
    private lazy var dataSource = DiffableDataSource.TableViewAdapter<Todo>(
        tableView: tableView,
        dataStack: CoreStoreDefaults.dataStack
    ) { tableView, indexPath, todo in
        guard
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        else {
            return UITableViewCell()
        }
        var content = cell.defaultContentConfiguration()
        content.text = "\(todo.text)"
        cell.contentConfiguration = content
        return cell
    }
    private let fetchLimit: Int = 5
    private var todosFetchOffset: Int = 0
    private lazy var todoPublisher = CoreStoreDefaults.dataStack.publishList(
        From<Todo>()
            .orderBy(.descending(\.$updatedAt))
            .tweak { [weak self] in
                $0.fetchOffset = self?.todosFetchOffset ?? 0
                $0.fetchLimit = self?.fetchLimit ?? 0
            }
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = addButton

        dataSource.apply(todoPublisher.snapshot)
        todosFetchOffset = todoPublisher.snapshot.numberOfItems

        todoPublisher.addObserver(self) { [weak self] listPublisher in
            guard let self else { return }
            let snapshot: ListSnapshot<Todo> = listPublisher.snapshot
            self.todosFetchOffset = listPublisher.snapshot.numberOfItems
            self.dataSource.apply(snapshot)
        }

        setupTableView()
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == todosFetchOffset - 2 else {
            return
        }
        print("load more here?")
    }
}
private extension ViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc func addButtonHandler() {
        CoreStoreDefaults.dataStack.perform { transaction in
            let todo = transaction.create(Into<Todo>())
            let todosCount = try? transaction.fetchCount(From<Todo>())
            todo.text = "Todo №\(todosCount ?? 0)"
        } completion: { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
