//
//  ListDataSource.swift
//  Mooskine
//
//  Created by Rudy James Jr on 6/6/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ListDataSource<EntityType: NSManagedObject, CellType: UITableViewCell>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let fetchedResultsController:NSFetchedResultsController<EntityType>
    let tableView: UITableView!
    let configure: (CellType, EntityType) -> Void
    let managedObjectContext: NSManagedObjectContext
    let cellReuseIdentifier: String
    
    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<EntityType>, sectionNameKeyPath: String?, cacheName: String?, cellReuseIdentifier: String, configure: @escaping (CellType, EntityType) -> Void) {
        self.tableView = tableView
        self.configure = configure
        self.managedObjectContext = managedObjectContext
        self.cellReuseIdentifier = cellReuseIdentifier
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("The fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CellType
        configure(cell, entity)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteEntity(indexPath: indexPath)
        default: () // Unsupported
        }
    }
    
    func deleteEntity(indexPath: IndexPath) {
        let entityToDelete = fetchedResultsController.object(at: indexPath)
        managedObjectContext.delete(entityToDelete)
        try? managedObjectContext.save()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break;
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            break;
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            break
        default:
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        default:
            break;
        }
    }
}
