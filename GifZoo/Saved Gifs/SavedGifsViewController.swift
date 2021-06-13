//
//  SavedGifsViewController.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 6/13/21.
//

import UIKit
import WebKit

class SavedGifsViewController: UIViewController {
    @IBOutlet weak var savedGifsTableView: UITableView!
    
    var viewModel: SavedGifsVCViewModel!
    var dataSource: UITableViewDiffableDataSource<SavedGifsVCViewModel.Section, GifRef>!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SavedGifsVCViewModel()
        savedGifsTableView.delegate = self
        setupUI()
        configureDataSource()
        updateGifsData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let gifRefs = viewModel.dataController.loadGifRef() as? [GifRef] {
            viewModel.gifRefs = gifRefs
            updateGifsData()
        }
        
    }
    
    private func setupUI() {
        
    }
    

}

extension SavedGifsViewController {
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<SavedGifsVCViewModel.Section, GifRef>(tableView: savedGifsTableView) { tableView, indexPath, gifRef in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedGifCell", for: indexPath) as? SavedGifTableViewCell else { return nil }
            cell.configure(title: gifRef.title)
            return cell
        }
    }
    
    func updateGifsData() {
        var snapshot = NSDiffableDataSourceSnapshot<SavedGifsVCViewModel.Section, GifRef>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.gifRefs)
        dataSource.apply(snapshot)
    }
}

extension SavedGifsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.gifRefs.count else { return }
        let gifRef = viewModel.gifRefs[indexPath.row]
        guard let url = gifRef.url else { return }
        UIApplication.shared.open(url)
    }
}

extension SavedGifsViewController: WKNavigationDelegate {
    
}
