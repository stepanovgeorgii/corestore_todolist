//
//  TodoModel.swift
//  TodoList_CoreStore
//
//  Created by Georgy Stepanov on 21.04.23.
//

import CoreStore

typealias Todo = V1.Todo

enum V1 {
    final class Todo: CoreStoreObject {
        @Field.Stored("text")
        var text: String = ""
        @Field.Stored("createdAt", dynamicInitialValue: { Date() })
        var createdAt: Date
        @Field.Stored("updatedAt", dynamicInitialValue: { Date() })
        var updatedAt: Date
    }
}
