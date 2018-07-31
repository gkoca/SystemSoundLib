//
//  TableViewController.swift
//  System Sound Lib
//
//  Created by Gökhan on 31.07.2018.
//  Copyright © 2018 Gökhan. All rights reserved.
//

import UIKit
import AudioToolbox

class TableViewController: UITableViewController {
    
    var soundList: [Sound] = [Sound]()
    var filteredSoundList: [Sound] = [Sound]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sound"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        loadAudioFiles()
    }

    func loadAudioFiles() {
        let fileManager = FileManager()
        let directoryURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds")
        
        let enumarator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles) { (url, err) -> Bool in
            return true
        }
        
        for e in enumarator! {
            if let url = e as? URL {
                if let resourceValue = try? url.resourceValues(forKeys: [.isDirectoryKey]) {
                    if let isDirectory = resourceValue.isDirectory, isDirectory == false {
                        var soundId : SystemSoundID = 0
                        AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
                        let sound = Sound(url: url, name: url.lastPathComponent, soundId: soundId)
                        soundList.append(sound)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredSoundList.count : soundList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if isFiltering() {
            cell.textLabel?.text = filteredSoundList[indexPath.row].name
            cell.detailTextLabel?.text = "sound Id: \(filteredSoundList[indexPath.row].soundId)"
        } else {
            cell.textLabel?.text = soundList[indexPath.row].name
            cell.detailTextLabel?.text = "sound Id: \(soundList[indexPath.row].soundId)"
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            AudioServicesPlayAlertSound(filteredSoundList[indexPath.row].soundId)
            print("playing sound id : \(filteredSoundList[indexPath.row].soundId)")
        } else {
            AudioServicesPlayAlertSound(soundList[indexPath.row].soundId)
            print("playing sound id : \(soundList[indexPath.row].soundId)")
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: Search
extension TableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSoundList = soundList.filter({ (sound: Sound) -> Bool in
            return sound.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
