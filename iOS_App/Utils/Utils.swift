//  Utils.swift
//  Tarasenko02
//
//  Created by Михаил Тарасенко on 12.03.2025.
//

import Foundation

func timeAgo(from date: Date) -> String {
    let now = Date()
    let calendar = Calendar.current
    
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
    
    if let years = components.year, years > 0 {
        return "\(years) years ago"
    } else if let months = components.month, months > 0 {
        return "\(months) month ago"
    } else if let days = components.day, days > 0 {
        return "\(days) day ago"
    } else if let hours = components.hour, hours > 0 {
        return "\(hours) hr. ago"
    } else if let minutes = components.minute, minutes > 0 {
        return "\(minutes) min. ago"
    } else {
        return "now"
    }
}

func formatRating(rating: Int) -> String {
    let ratingStr = String(rating)
    
    if ratingStr.count <= 4 {
        return ratingStr
    }
    
    if rating < 1_000_000 {
        let thousands = rating / 1000
        return "\(thousands)K"
    } else {
        let millions = rating / 1_000_000
        return "\(millions)M"
    }
}

func isPostSaved() -> Bool {
    let randomNumber = Int.random(in: 0...1)
    return randomNumber != 0
}
