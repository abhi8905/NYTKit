//
//  AppConstants.swift
//  NYTKit
//
//  Created by Abhinav Jha on 11/07/2025.
//


import Foundation

public enum AppConstants {
    public enum Titles {
        public static let articleList = "NY Times Popular"
        public static let detailTitle = "Article Details"
    }

    public enum Links {
        public static let title = "Read Full Article on NYTimes.com"
    }
    
    public enum Filters {
        public static let endpointMenuTitle = "Endpoint"
        public static let periodMenuTitle = "Period"
    }
    
    public enum ErrorMessages {
        public static let noArticlesFound = "No articles found for the selected criteria."
        public static let genericTitle = "An Error Occurred"
        public static let noArticles = "No articles found."
    }
    
    public enum OfflineMessages {
        public static let title = "No Internet Connection"
        public static let description = "Please check your connection and try again."
    }
    
    public enum Images {
        public static let filter = "line.3.horizontal.decrease.circle"
        public static let offline = "wifi.slash"
        public static let error = "exclamationmark.triangle"
        public static let filterIcon = "line.3.horizontal.decrease.circle"
        public static let calendarIcon = "calendar"
        public static let placeholder = "photo.circle.fill"
    }
    
    public enum Timings {
        public static let filterDebounce: TimeInterval = 0.5
    }
    
    public enum ButtonTitles {
        public static let retry = "Retry"
    }
}
