//
//  CoreStoreManager.swift
//  TodoList_CoreStore
//
//  Created by Georgy Stepanov on 21.04.23.
//

import CoreStore
import Foundation

protocol CoreStoreManagerProtocol {
    func setup(completion: @escaping () -> Void)
}

final class CoreStoreManager: CoreStoreManagerProtocol {
    private enum Keys: String {
        case sqliteFileName = "TodoList_CoreStore.sqlite"
    }
    
    // MARK: - Private
    private let sqliteStore = SQLiteStore(
        fileName: Keys.sqliteFileName.rawValue,
        localStorageOptions: .allowSynchronousLightweightMigration
    )
    
    private let dataStack = DataStack(
        CoreStoreSchema(
            modelVersion: "V1",
            entities: [
                Entity<V1.Todo>("Todo"),
            ]
        )
    )
    
    // MARK: - CoreStoreManagerProtocol
    
    func setup(completion: @escaping () -> Void) {
        let _ = dataStack.addStorage(sqliteStore) { result in
            switch result {
            case .success(let storage):
                print("Successfully added sqlite store: \(storage)")
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        CoreStoreDefaults.dataStack = dataStack
    }
}
