//
//  StripeConfig.swift
//  RePlate
//
//  PUBLISHABLE key only — safe to embed in the app and commit.
//  NEVER put the secret key here. Secret key lives in Supabase secrets only.
//
import Foundation

enum StripeConfig {
    // Replace with your real test publishable key from https://dashboard.stripe.com/test/apikeys
    static let publishableKey = "pk_test_51U07yuQaYmnWxGuAdZ88lspr1WWRK0QFYQjw1tiR0ugRZ3y4pvr6kF3uwUWXezjbxHC8arKyCO05fND3E4JorPRJ00GrXu2fC6"

    // Supabase Edge Function URLs
    static let createPaymentIntentURL = "\(SupabaseConfig.url.absoluteString)/functions/v1/create-payment-intent"
    static let webhookURL             = "\(SupabaseConfig.url.absoluteString)/functions/v1/stripe-webhook"
}
