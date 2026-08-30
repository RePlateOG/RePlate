//
//  SupabaseConfig.swift
//  RePlate
//
//  Central Supabase client for the app.
//
//  SETUP (one time, in Xcode):
//  1. File > Add Package Dependencies… > https://github.com/supabase/supabase-swift
//     Add the "Supabase" library product to the RePlate target.
//  2. Uncomment the import and SupabaseClient lines below, then build.
//
//  NOTE: The key below is the PUBLISHABLE (anon) key. It is designed to be shipped in
//  client apps and is protected by Row Level Security in the database. NEVER put the
//  Supabase "secret" / service_role key in the app or in git.
//

import Foundation

enum SupabaseConfig {
    static let url = URL(string: "https://qubatmvrhcvllqwakcgk.supabase.co")!
    static let publishableKey = "sb_publishable_KhEq7_euGj9PkByWHOXPZA_MVMJhcjV"
}

// TODO: Uncomment after adding supabase-swift package in Xcode:
// import Supabase
// let supabase = SupabaseClient(
//     supabaseURL: SupabaseConfig.url,
//     supabaseKey: SupabaseConfig.publishableKey
// )
