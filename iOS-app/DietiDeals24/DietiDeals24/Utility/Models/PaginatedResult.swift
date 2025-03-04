//
//  PaginatedResult.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

struct PaginatedResult<T: Decodable>: Decodable {
    let results: [T]
    let totalRecords: Int
    let page: Int
    let pageSize: Int
}
