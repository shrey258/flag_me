# Flag Me - Frontend Application

A Flutter-based gift recommendation and occasion management application that helps users find the perfect gifts for their loved ones.

## Overview

Flag Me is a cross-platform mobile application that provides a user-friendly interface for managing occasions, searching for products across e-commerce platforms, and generating personalized gift recommendations using AI.

## Features

- **User Authentication**: Secure login and registration using Supabase
- **Occasion Management**: Track birthdays, anniversaries, and other special events
- **Gift Recommendations**: AI-powered gift suggestions based on recipient details
- **Product Search**: Search for products across multiple e-commerce platforms
- **Message Generation**: Create personalized messages for special occasions
- **Wishlist Management**: Save and organize gift ideas
- **Retro-themed UI**: Beautiful and distinctive user interface
- **Offstage WebView**: Hidden WebView for extracting HTML from e-commerce sites

## Technical Implementation

### Architecture

The application follows a provider-based architecture using Riverpod for state management. Key components include:

- **Screens**: UI components for different app sections
- **Providers**: State management using Riverpod
- **Models**: Data structures for occasions, products, etc.
- **Services**: API communication with the backend
- **Widgets**: Reusable UI components

### Key Components

#### Main Application (`main.dart`)
- Initializes the application and sets up providers
- Handles authentication state and navigation
- Implements the main screen with bottom navigation

#### Home Screen (`HomePage`)
- Displays upcoming occasions
- Shows a hero card for quick actions
- Provides navigation to add new occasions

#### Product Search (`ProductSearchScreen`)
- Allows searching for products across e-commerce platforms
- Implements filtering by price range and platform
- Displays product cards with images, prices, and links

#### Occasion Management
- `AddOccasionScreen`: Form for adding new occasions
- `OccasionDetailsScreen`: View and manage occasion details

#### Gift Recommendations
- Uses the backend API to get AI-powered gift suggestions
- Displays recommendations based on recipient details

#### WebView Implementation
- Implements an offstage WebView to extract HTML from e-commerce sites
- Handles JavaScript injection for data extraction
- Manages cookies and session data

### State Management

The application uses Riverpod for state management with the following providers:

- `authProvider`: Manages authentication state
- `occasionsProvider`: Manages occasion data
- `navigationProvider`: Controls bottom navigation
- `wishListProvider`: Manages saved gift ideas
- `themeProvider`: Controls application theme

## Setup and Installation

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- A Supabase account for authentication

### Environment Setup

1. Create a `.env` file in the project root with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   API_BASE_URL=your_backend_api_url
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Common Issues and Solutions

- **WebView Extraction**: The WebView might not fully load before extraction attempts. Implement proper loading detection.
- **Mobile vs Desktop Sites**: E-commerce sites often have different HTML structures for mobile and desktop versions.
- **Null Values**: Handle cases where product data fields (price, URL, image) might be null.

## Future Improvements

- Implement caching for product searches
- Add offline support for occasion management
- Enhance UI animations and transitions
- Implement deep linking for sharing occasions
- Add notification system for upcoming events