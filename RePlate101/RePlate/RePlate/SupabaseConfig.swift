//
//  SupabaseConfig.swift
//  RePlate
//
//  NOTE: The key below is the publishable (anon) key. It is designed to be shipped in
//  client apps and is protected by Row Level Security in the database. NEVER put the
//  Supabase service_role key in the app or in git.
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://cahwspfvdgnkigxuezee.supabase.co")!
    static let publishableKey = "sb_publishable_djVRL7TQENkfAkO3XVPbhw_A4N4JMZK"
}

// Shared Supabase client — used throughout the app for auth, database, and storage.
let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.publishableKey,
    options: SupabaseClientOptions(
        auth: SupabaseClientOptions.AuthOptions(
            emitLocalSessionAsInitialSession: true
        )
    )
)
