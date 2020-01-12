import Foundation
import EasyPeasy

class MeasurementDetailViewController: UIViewController {
    let model: MeasurementModel
    let tableView = UITableView()
    
    init(withModel: MeasurementModel) {
        self.model = withModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        self.view.backgroundColor = .white
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryDetailCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .clear
        
        self.tableView.easy.layout(Edges())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Detail"
    }
}

extension MeasurementDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.properties().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "HistoryDetailCell")

        cell.textLabel?.text = model.properties()[indexPath.row].0
        cell.detailTextLabel?.text = model.properties()[indexPath.row].1
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        cell.backgroundColor = .systemBlue
        cell.accessoryType = .detailButton
        
        return cell
    }
}
