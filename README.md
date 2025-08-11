# DietiDeals24

Oreste Leone - Giuseppe Falso

DietiDeals24 is a full-stack application designed as a modern online auction platform. It consists of a robust backend built with .NET 8 and a feature-rich iOS application developed with SwiftUI. The project showcases a wide range of skills in backend development, cloud architecture, and native mobile development.

## Backend

The backend of DietiDeals24 is built on a Monolith Services-Oriented architecture using .NET 8, ensuring scalability, maintainability, and high performance. It leverages a range of AWS cloud services to provide a secure, reliable, and event-driven platform.

### Architecture

The backend is composed of the following key components:

*   **REST API:** A powerful and secure RESTful API built with ASP.NET Core that serves as the primary interface for the iOS application. It handles all the business logic, from user authentication to auction management.
*   **Data Access Layer:** A dedicated layer that encapsulates all database interactions using Entity Framework Core, ensuring a clean separation of concerns and a modular design.
*   **Database:** A PostgreSQL database is used for data persistence, providing a reliable and scalable solution for storing auction and user data.
*   **Serverless Functions:** AWS Lambda functions are used to handle asynchronous and event-driven tasks, such as processing auction expirations and user registration confirmations.
*   **Containerization:** The entire backend is containerized using Docker, allowing for easy deployment and consistent environments across development and production.

### Technologies

*   **.NET 8:** The latest version of the .NET framework, providing high performance, long-term support, and a rich ecosystem of libraries.
*   **ASP.NET Core:** A modern, cross-platform framework for building web APIs and microservices.
*   **Entity Framework Core:** A powerful and flexible object-relational mapper (O/RM) for .NET.
*   **PostgreSQL:** A robust and open-source object-relational database system.
*   **Docker:** A containerization platform for building, shipping, and running applications.
*   **Swagger:** An OpenAPI implementation for documenting and testing the REST API.
*   **FluentValidation:** A popular .NET library for building strongly-typed validation rules.

### Cloud Services (AWS)

*   **Amazon Cognito:** A fully managed identity service for user authentication and authorization.
*   **Amazon S3:** A scalable object storage service for storing auction images and other static assets.
*   **Amazon SNS (Simple Notification Service):** A fully managed messaging service for sending push notifications to the iOS app.
*   **Amazon EventBridge:** A serverless event bus that connects application components with data from a variety of sources.
*   **AWS Lambda:** A serverless compute service that runs code in response to events and automatically manages the underlying compute resources.
*   **AWS Scheduler:** A fully managed service for scheduling one-time or recurring tasks.

## iOS App

The DietiDeals24 iOS app is a native application built with Swift and SwiftUI, providing a modern, responsive, and user-friendly experience. It is designed to interact seamlessly with the backend, offering a wide range of features for both buyers and sellers.

### Architecture

The app is built using a modern, feature-based architecture, with a clear separation of concerns between the UI, business logic, and networking layers. This approach ensures that the codebase is modular, scalable, and easy to maintain.

*   **SwiftUI:** The entire user interface is built with SwiftUI, Apple's modern declarative UI framework.
*   **MVVM (Model-View-ViewModel):** The app follows the MVVM design pattern to separate the UI from the business logic, making the code more testable and maintainable.
*   **Feature-Based Project Structure:** The project is organized by features (e.g., `AuthenticationUseCase`, `AuctionDetailMain`, `ExploreTab`), making it easy to navigate and understand the codebase.
*   **Dependency Injection:** The app uses dependency injection to manage the dependencies between different components, improving testability and flexibility.
*   **Networking:** A dedicated networking layer handles all communication with the backend REST API, ensuring that all network requests are handled efficiently and reliably.

### Technologies

*   **Swift:** Apple's modern, safe, and powerful programming language.
*   **SwiftUI:** A declarative UI framework for building apps for all Apple platforms.
*   **Combine:** A framework for processing values over time, used for handling asynchronous events and data streams.
*   **Xcode:** The integrated development environment (IDE) for building apps for Apple platforms.

### Features

*   **User Authentication:** Secure user registration and login using AWS Cognito.
*   **Auction Browsing:** A rich user interface for browsing and searching for auctions.
*   **Auction Creation:** A simple and intuitive interface for creating new auctions.
*   **Bidding:** Real-time bidding on auctions.
*   **Push Notifications:** Real-time notifications for new bids, auction endings, and other important events.
*   **User Profile:** A dedicated section for managing user information and tracking auctions.


