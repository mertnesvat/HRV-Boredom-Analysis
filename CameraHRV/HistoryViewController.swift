import Foundation
import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var list: [MeasurementModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "History"
        FirebaseHelper.shared.fetchMeasurementHistory { [weak self] (model) in
            self?.list = model
            self?.tableView.reloadData()
        }
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = MeasurementDetailViewController(withModel: self.list[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "HistoryCell")
        
        cell.textLabel?.text = String(format: "%.2f", self.list[indexPath.row].RMSSD)
        cell.detailTextLabel?.text = self.list[indexPath.row].recordingDate
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        cell.backgroundColor = .systemBlue
        cell.accessoryType = .detailDisclosureButton
        cell.tintColor = .white
        
        return cell
    }
}



