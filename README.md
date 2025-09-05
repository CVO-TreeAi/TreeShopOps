# TreeShop Ops

**TreeShop Ops** is a comprehensive iOS application for tree service businesses to manage pricing, proposals, and customer information.

## Features

### 🌳 **Pricing Calculator**
- Tree removal, stump removal, and pruning cost calculations
- Tax and discount calculations
- Project location and zip code tracking

### 📋 **Proposal Management (CRUD)**
- Create, read, update, and delete proposals
- Status tracking (Draft, Sent, Accepted, Rejected, Expired)
- Professional proposal details with customer information
- Search and filter proposals by status
- Integration with pricing calculator

### 👥 **Customer Management**
- Complete customer database
- Customer contact information and project history
- Integration with proposals and pricing

## Design

- **TreeShop Brand Colors**: Accent green (#00FF41), TreeShop black (#040404), TreeShop blue (#1c4c9c)
- Modern glassmorphism UI design
- Dark theme optimized interface
- Native iOS experience with SwiftUI

## Project Structure

```
TreeShopOps/
├── TreeShopOpsApp.swift          # Main app entry point
├── MainTabView.swift             # Tab navigation
├── ContentView.swift             # Pricing calculator
├── ProposalModel.swift           # Proposal data model & manager
├── ProposalListView.swift        # Proposals list with CRUD
├── AddEditProposalView.swift     # Create/edit proposals
├── ProposalDetailView.swift      # View proposal details
├── SaveProposalView.swift        # Quick save from calculator
├── CustomerModel.swift           # Customer data model & manager
├── CustomerListView.swift        # Customer management
├── CustomerDetailView.swift      # Customer details
├── AddEditCustomerView.swift     # Create/edit customers
├── PricingModel.swift           # Pricing calculations
├── SettingsView.swift           # App settings
└── Assets.xcassets/             # App icons and colors
```

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository
2. Open `TreeShopOps.xcodeproj` in Xcode
3. Build and run the project

## Usage

The app consists of three main tabs:

1. **Pricing** - Calculate costs for tree services
2. **Proposals** - Manage customer proposals with full CRUD operations
3. **Customers** - Manage customer database

Create pricing calculations and save them as professional proposals that can be tracked through their lifecycle from draft to completion.

---

**TreeShop Ops** - Streamlining tree service business operations.