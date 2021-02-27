//
//  ViewController.swift
//  GifZoo
//
//  Created by Andrew Struck-Marcell on 12/14/20.
//

import UIKit
import AVFoundation

class GifDisplayViewController: UIViewController {
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var gifSearchBar: UISearchBar!
    @IBOutlet weak var trendingButton: UIButton!
    @IBOutlet weak var randomGifButton: UIButton!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    @IBOutlet weak var numGifsControl: UISegmentedControl!
    
    var mp4Containerview: UIView!
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var viewModel: GifDisplayVCViewModel!
    var dataSource: UICollectionViewDiffableDataSource<GifDisplayVCViewModel.Section, Gif>!
    var isPresentingMP4 = false
    
    @IBAction func trendingButtonTapped(_ sender: UIButton) {
        // TODO: make these lines of code more DRY
        viewModel.mp4Item = nil
        viewModel.mp4 = nil
        gifCollectionView.layer.sublayers?.first(where: { $0 is AVPlayerLayer })?.removeFromSuperlayer()
        viewModel.gifs = []
        viewModel.gifsRetrievedImages = [:]
        let numGifs: Int = Int(numGifsControl.titleForSegment(at: numGifsControl.selectedSegmentIndex) ?? "1") ?? 1
        viewModel.getGifs(withText: "", endpoint: .trending, limit: numGifs) { [weak self] in
            DispatchQueue.main.async {
                self?.configureDataSource()
                self?.updateGifsData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func randomGifTapped(_ sender: UIButton) {
        guard let text = gifSearchBar.text else { return }
        viewModel.mp4Item = nil
        viewModel.mp4 = nil
        gifCollectionView.layer.sublayers?.first(where: { $0 is AVPlayerLayer })?.removeFromSuperlayer()
        
        viewModel.getRandomGif(atText: text) { [weak self] in
            guard let self = self else { return }
            guard self.viewModel.mp4Item != nil else { return }
            DispatchQueue.main.async {
                self.viewModel.gifs = []
                self.updateGifsData()
                
                let playerLayer = AVPlayerLayer(player: self.viewModel.mp4)
                playerLayer.frame = CGRect(x: 0, y: 0, width: self.gifCollectionView.bounds.width, height: self.gifCollectionView.bounds.height)
                self.gifCollectionView.layer.addSublayer(playerLayer)
                self.playMP4()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        
        hideMP4Popup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifCollectionView.collectionViewLayout = createLayout()
        viewModel = GifDisplayVCViewModel()
        gifCollectionView.delegate = self
        setupUI()
        configureDataSource()
        updateGifsData()
    }
    
    private func setupUI() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        numGifsControl.selectedSegmentIndex = 0
        numGifsControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 18)!], for: .normal)
        numGifsControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Verdana", size: 30)!], for: .selected)
        gifSearchBar.searchTextField.font = UIFont(name: "Verdana", size: 18)
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc private func hideMP4Popup() {
        guard mp4Containerview != nil else { return }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [.curveEaseIn, .layoutSubviews]) {
            self.mp4Containerview.widthAnchor.constraint(equalToConstant: 0).isActive = true
            self.mp4Containerview.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            self.view.layoutIfNeeded()
        }
        mp4Containerview.removeFromSuperview()
        mp4Containerview = nil
        isPresentingMP4 = false
        
        grayView.isHidden = true
    }
    
    
}

extension GifDisplayViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = gifSearchBar.text else { return }
        performSearch(withText: text)
        searchBar.resignFirstResponder()
    }
    
    private func performSearch(withText text: String) {
        activityIndicator.startAnimating()
        
        viewModel.mp4Item = nil
        viewModel.mp4 = nil
        gifCollectionView.layer.sublayers?.first(where: { $0 is AVPlayerLayer })?.removeFromSuperlayer()
        viewModel.gifs = []
        viewModel.gifsRetrievedImages = [:]
        let numGifs: Int = Int(numGifsControl.titleForSegment(at: numGifsControl.selectedSegmentIndex) ?? "1") ?? 1
        viewModel.getGifs(withText: text, endpoint: .search, limit: numGifs) { [weak self] in
            DispatchQueue.main.async {
                self?.configureDataSource()
                self?.updateGifsData()
                self?.activityIndicator.stopAnimating()
            }
        }
        
    }
    
}


//Set collection view data source and update UI
extension GifDisplayViewController {
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<GifDisplayVCViewModel.Section, Gif>(collectionView: gifCollectionView, cellProvider: { [weak self] (collectionView, indexPath, gif) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifCell", for: indexPath) as? GifCollectionViewCell
            cell?.configure(withImage: self?.viewModel.gifsRetrievedImages[gif.id]?[(gif.metadata?.fixedHeightSmall)!])
            return cell
        })
    }
    
    func updateGifsData() {
        var snapshot = NSDiffableDataSourceSnapshot<GifDisplayVCViewModel.Section, Gif>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.gifs)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension GifDisplayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let gif = dataSource.itemIdentifier(for: indexPath) else {
            gifCollectionView.deselectItem(at: indexPath, animated: true)
            return nil
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            let saveAction = self.saveGifAction(gif)
            let searchAction = self.searchGifsAction(gif)
            let shareAction = self.shareGifsAction(gif)
            return UIMenu(title: "", children: [saveAction, searchAction, shareAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isPresentingMP4 else {
            gifCollectionView.deselectItem(at: indexPath, animated: false)
            hideMP4Popup()
            return
        }
        guard let gif = dataSource.itemIdentifier(for: indexPath) else {
            gifCollectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        let cvAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellFrame = cvAttributes?.frame
        let cellFrameInSuperview = collectionView.convert(cellFrame!, to: view)
        
        let width = CGFloat(Float(gif.metadata?.mp4?.width ?? "300") ?? 300)
        let height = CGFloat(Float(gif.metadata?.mp4?.height ?? "300") ?? 300)
        
        presentMP4(gif, fromCellFrame: cellFrameInSuperview, width: width, height: height)
        isPresentingMP4.toggle()
    }
    
    private func presentMP4(_ gif: Gif, fromCellFrame cellFrame: CGRect, width: CGFloat, height: CGFloat) {
        hideMP4Popup()
        grayView.isHidden = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideMP4Popup))
        grayView.addGestureRecognizer(tap)
        
        mp4Containerview = UIView(frame: CGRect(x: cellFrame.minX, y: cellFrame.minY, width: 0, height: 0))
        mp4Containerview.backgroundColor = .white
        view.addSubview(mp4Containerview)
        view.bringSubviewToFront(grayView)
        view.bringSubviewToFront(mp4Containerview)
        let maxWidth = view.bounds.size.width * 0.98
        let displayWidth = maxWidth < width ? maxWidth : width
        let displayHeight = height * (displayWidth / width)
        
        viewModel.getMP4(atURL: (URL(string: (gif.metadata?.mp4?.mp4)!))!, forID: gif.id) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { /// FIXME: this delay is not 100% perfect to load mp4ContainerView
                UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: [.calculationModeLinear, .layoutSubviews]) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                        self.mp4Containerview.frame = CGRect(x: self.view.bounds.midX - displayWidth/4, y: self.view.bounds.midY - displayHeight/4, width: displayWidth/2, height: displayHeight/2)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.25) {
                        self.mp4Containerview.transform = CGAffineTransform(scaleX: 2, y: 2)
                    }
                    self.view.layoutIfNeeded()
                    self.addMP4()
                }
            }
        }
        
    }
    
    private func addMP4() {
        let playerLayer = AVPlayerLayer(player: viewModel.mp4)
        playerLayer.frame = mp4Containerview.bounds
        self.mp4Containerview.layer.addSublayer(playerLayer)
        
        playMP4()
    }
    
    private func playMP4() {
        guard viewModel.mp4Item != nil else { return }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(self.mp4DidFinish),
                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                       object: viewModel.mp4Item!)
        
        viewModel.mp4?.actionAtItemEnd = .none
        viewModel.mp4?.play()
    }
    
    @objc func mp4DidFinish() {
        viewModel.mp4?.seek(to: CMTime(value: .zero, timescale: .init(1)))
        viewModel.mp4?.play()
    }
    
}

extension GifDisplayViewController: ContextMenu {
    func save(_ gif: Gif) {
        print("Save Gif URL here")
    }
    
    func search(_ gif: Gif) {
        self.gifSearchBar.text = gif.title
        self.performSearch(withText: gif.title)
    }
    
    func share(_ gif: Gif) {
        DispatchQueue.global(qos: .background).async {
            if let mp4URL = URL(string: (gif.metadata?.mp4?.mp4)!), let mp4Data =  NSData(contentsOf: mp4URL) {
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let docDirectory = paths[0]
                let filePath = "\(docDirectory)/tempFile.mp4"
                DispatchQueue.main.async {
                    mp4Data.write(toFile: filePath, atomically: true)
                    let ac = UIActivityViewController(activityItems: [mp4URL], applicationActivities: nil)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
}


extension GifDisplayViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(92))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}


