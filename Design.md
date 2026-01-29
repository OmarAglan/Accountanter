# Design Document
## نظام إدارة قطع غيار المعدات الثقيلة
### Heavy Equipment Parts Management System

---

## 1. Project Overview

| Item | Detail |
|------|--------|
| **Project Name** | نظام إدارة المخزون والفواتير |
| **Business Type** | Heavy Equipment Parts & Machines |
| **Platform** | Windows Desktop (Windows 10) |
| **Framework** | C# WPF (.NET 6 or .NET 8) |
| **Database** | SQLite |
| **Language** | Arabic (RTL) |
| **Currency** | ج.م (Egyptian Pound) |

---

## 2. Technical Stack

```
├── Frontend: WPF (XAML)
├── Backend: C# .NET 8
├── Database: SQLite
├── ORM: Entity Framework Core
├── PDF Export: QuestPDF (free) or iTextSharp
├── UI Framework: MaterialDesignInXAML or HandyControl
├── Icons: Material Design Icons
└── Reporting: Built-in or LiveCharts for graphs
```

---

## 3. Database Design

### 3.1 Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────────┐       ┌─────────────┐
│  Suppliers  │       │    Products     │       │ Categories  │
├─────────────┤       ├─────────────────┤       ├─────────────┤
│ Id          │       │ Id              │       │ Id          │
│ Name        │──────<│ SupplierId (FK) │       │ Name        │
│ Phone       │       │ CategoryId (FK) │>──────│ Description │
│ Address     │       │ Name            │       └─────────────┘
│ Notes       │       │ SKU (optional)  │
└─────────────┘       │ Brand (optional)│
                      │ PurchasePrice   │
                      │ SellingPrice    │
                      │ Quantity        │
                      │ LowStockAlert   │
                      │ Description     │
                      └────────┬────────┘
                               │
                               │
┌─────────────┐       ┌────────┴────────┐       ┌─────────────┐
│  Customers  │       │  InvoiceItems   │       │  Invoices   │
├─────────────┤       ├─────────────────┤       ├─────────────┤
│ Id          │       │ Id              │       │ Id          │
│ Name        │──────<│ InvoiceId (FK)  │>──────│ InvoiceNo   │
│ Phone       │       │ ProductId (FK)  │       │ CustomerId  │
│ Address     │       │ Quantity        │       │ Type        │
│ CompanyName │       │ UnitPrice       │       │ Date        │
│ Balance     │       │ Discount        │       │ DueDate     │
│ Notes       │       │ Total           │       │ Subtotal    │
└──────┬──────┘       └─────────────────┘       │ Discount    │
       │                                         │ Total       │
       │                                         │ PaidAmount  │
       │              ┌─────────────────┐       │ Status      │
       │              │    Payments     │       │ Notes       │
       │              ├─────────────────┤       └─────────────┘
       └─────────────>│ Id              │              │
                      │ CustomerId (FK) │              │
                      │ InvoiceId (FK)  │<─────────────┘
                      │ Amount          │
                      │ Method          │
                      │ Date            │
                      │ Notes           │
                      └─────────────────┘

┌─────────────┐       ┌─────────────────┐
│    Users    │       │    Settings     │
├─────────────┤       ├─────────────────┤
│ Id          │       │ Id              │
│ Username    │       │ Key             │
│ Password    │       │ Value           │
│ Role        │       └─────────────────┘
│ Permissions │
│ IsActive    │       ┌─────────────────┐
└─────────────┘       │  Notifications  │
                      ├─────────────────┤
                      │ Id              │
                      │ Type            │
                      │ Message         │
                      │ IsRead          │
                      │ Date            │
                      └─────────────────┘
```

---

### 3.2 Tables Schema

#### Customers (العملاء)
```sql
CREATE TABLE Customers (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Name NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    CompanyName NVARCHAR(100),
    Balance DECIMAL(18,2) DEFAULT 0,
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT 1
);
```

#### Categories (الأصناف)
```sql
CREATE TABLE Categories (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200)
);
```

#### Suppliers (الموردين)
```sql
CREATE TABLE Suppliers (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Name NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    Email NVARCHAR(100),
    Notes NVARCHAR(500)
);
```

#### Products (المنتجات)
```sql
CREATE TABLE Products (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Name NVARCHAR(200) NOT NULL,
    SKU NVARCHAR(50),
    Brand NVARCHAR(100),
    CategoryId INTEGER,
    SupplierId INTEGER,
    PurchasePrice DECIMAL(18,2) NOT NULL,
    SellingPrice DECIMAL(18,2) NOT NULL,
    Quantity INTEGER DEFAULT 0,
    LowStockThreshold INTEGER DEFAULT 1,
    Description NVARCHAR(500),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT 1,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
    FOREIGN KEY (SupplierId) REFERENCES Suppliers(Id)
);
```

#### Invoices (الفواتير)
```sql
CREATE TABLE Invoices (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceNumber NVARCHAR(50) NOT NULL UNIQUE,
    CustomerId INTEGER NOT NULL,
    Type NVARCHAR(20) NOT NULL, -- 'Sale' or 'Return'
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    DueDate DATETIME,
    Subtotal DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    Total DECIMAL(18,2) NOT NULL,
    PaidAmount DECIMAL(18,2) DEFAULT 0,
    Status NVARCHAR(20) DEFAULT 'Unpaid', -- 'Paid', 'Partial', 'Unpaid', 'Overdue'
    Notes NVARCHAR(500),
    CreatedBy INTEGER,
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
    FOREIGN KEY (CreatedBy) REFERENCES Users(Id)
);
```

#### InvoiceItems (عناصر الفاتورة)
```sql
CREATE TABLE InvoiceItems (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceId INTEGER NOT NULL,
    ProductId INTEGER NOT NULL,
    Quantity INTEGER NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    UnitCost DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    Total DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (InvoiceId) REFERENCES Invoices(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
```

#### Payments (المدفوعات)
```sql
CREATE TABLE Payments (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerId INTEGER NOT NULL,
    InvoiceId INTEGER,
    Amount DECIMAL(18,2) NOT NULL,
    Method NVARCHAR(50) NOT NULL, -- 'Cash', 'VodafoneCash', 'InstaPay'
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Notes NVARCHAR(200),
    IsAdvancePayment BOOLEAN DEFAULT 0,
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
    FOREIGN KEY (InvoiceId) REFERENCES Invoices(Id)
);
```

#### Users (المستخدمين)
```sql
CREATE TABLE Users (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    FullName NVARCHAR(100),
    Role NVARCHAR(20) DEFAULT 'User', -- 'Admin', 'User'
    Permissions NVARCHAR(500), -- JSON string
    IsActive BOOLEAN DEFAULT 1,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Settings (الإعدادات)
```sql
CREATE TABLE Settings (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Key NVARCHAR(50) NOT NULL UNIQUE,
    Value NVARCHAR(500)
);
```

#### Notifications (الإشعارات)
```sql
CREATE TABLE Notifications (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Type NVARCHAR(50) NOT NULL, -- 'LowStock', 'Overdue', 'DueSoon'
    Title NVARCHAR(100),
    Message NVARCHAR(500),
    RelatedId INTEGER,
    IsRead BOOLEAN DEFAULT 0,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 4. Application Structure

```
HeavyEquipmentSystem/
│
├── App.xaml
├── App.xaml.cs
│
├── Assets/
│   ├── Images/
│   │   └── logo.png
│   └── Fonts/
│       └── Cairo-Regular.ttf
│
├── Data/
│   ├── AppDbContext.cs
│   ├── DatabaseInitializer.cs
│   └── Repositories/
│       ├── IRepository.cs
│       ├── CustomerRepository.cs
│       ├── ProductRepository.cs
│       ├── InvoiceRepository.cs
│       └── ...
│
├── Models/
│   ├── Customer.cs
│   ├── Product.cs
│   ├── Invoice.cs
│   ├── InvoiceItem.cs
│   ├── Payment.cs
│   ├── Category.cs
│   ├── Supplier.cs
│   ├── User.cs
│   └── Notification.cs
│
├── Services/
│   ├── AuthService.cs
│   ├── BackupService.cs
│   ├── NotificationService.cs
│   ├── ReportService.cs
│   ├── PrintService.cs
│   └── PdfExportService.cs
│
├── ViewModels/
│   ├── BaseViewModel.cs
│   ├── MainViewModel.cs
│   ├── DashboardViewModel.cs
│   ├── CustomersViewModel.cs
│   ├── ProductsViewModel.cs
│   ├── InvoicesViewModel.cs
│   ├── ReportsViewModel.cs
│   └── SettingsViewModel.cs
│
├── Views/
│   ├── MainWindow.xaml
│   ├── LoginWindow.xaml
│   ├── Dashboard/
│   │   └── DashboardView.xaml
│   ├── Customers/
│   │   ├── CustomersListView.xaml
│   │   └── CustomerFormView.xaml
│   ├── Products/
│   │   ├── ProductsListView.xaml
│   │   └── ProductFormView.xaml
│   ├── Invoices/
│   │   ├── InvoicesListView.xaml
│   │   ├── InvoiceFormView.xaml
│   │   └── PaymentFormView.xaml
│   ├── Reports/
│   │   └── ReportsView.xaml
│   └── Settings/
│       └── SettingsView.xaml
│
├── Controls/
│   ├── SearchableComboBox.xaml
│   ├── NotificationPanel.xaml
│   └── StatCard.xaml
│
├── Helpers/
│   ├── Constants.cs
│   ├── Converters.cs
│   └── Validators.cs
│
└── Resources/
    ├── Styles.xaml
    ├── Colors.xaml
    └── ArabicResources.xaml
```

---

## 5. User Interface Design

### 5.1 Color Scheme

```
Primary Color:     #2196F3 (Blue)
Secondary Color:   #1976D2 (Dark Blue)
Accent Color:      #4CAF50 (Green)
Warning Color:     #FF9800 (Orange)
Danger Color:      #F44336 (Red)
Background:        #F5F5F5 (Light Gray)
Card Background:   #FFFFFF (White)
Text Primary:      #212121 (Dark Gray)
Text Secondary:    #757575 (Gray)
```

### 5.2 Main Layout (RTL)

```
┌────────────────────────────────────────────────────────────┐
│                        Header Bar                          │
│  [🔔 Notifications] [👤 User Name]              [Logo]     │
├──────────────────────────────────────────┬─────────────────┤
│                                          │                 │
│                                          │   الرئيسية  🏠  │
│                                          │                 │
│                                          │   الفواتير  📄  │
│                                          │                 │
│           Main Content Area              │   العملاء   👥  │
│                                          │                 │
│                                          │   المنتجات  📦  │
│                                          │                 │
│                                          │   المخزون   🏪  │
│                                          │                 │
│                                          │   التقارير  📊  │
│                                          │                 │
│                                          │   الإعدادات ⚙️  │
│                                          │                 │
├──────────────────────────────────────────┴─────────────────┤
│                        Status Bar                          │
│  [Database Status]        [Date/Time]        [Version]     │
└────────────────────────────────────────────────────────────┘
```

### 5.3 Dashboard Screen

```
┌────────────────────────────────────────────────────────────┐
│                         لوحة التحكم                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │  مبيعات اليوم │ │ إجمالي المخزون│ │ عملاء مدينين │       │
│  │              │ │              │ │              │       │
│  │  5,000 ج.م   │ │     150      │ │      12      │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                    الإشعارات                         │  │
│  │  ⚠️  منتج "فلتر زيت" وصل للحد الأدنى                │  │
│  │  🔴 فاتورة #1042 متأخرة عن السداد                   │  │
│  │  ⏰ فاتورة #1045 تستحق غداً                         │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                  إجراءات سريعة                        │ │
│  │                                                       │ │
│  │  [➕ فاتورة جديدة]  [👤 عميل جديد]  [📦 منتج جديد]  │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                  آخر الفواتير                         │ │
│  │  ┌──────┬──────────┬──────────┬─────────┬─────────┐  │ │
│  │  │ رقم  │  العميل  │  المبلغ   │ الحالة  │ التاريخ │  │ │
│  │  ├──────┼──────────┼──────────┼─────────┼─────────┤  │ │
│  │  │ 1050 │  أحمد    │ 2,500    │  مدفوع  │ 15/01  │  │ │
│  │  │ 1049 │  محمد    │ 1,800    │  جزئي   │ 15/01  │  │ │
│  │  │ 1048 │  علي     │ 3,200    │ غير مدفوع│ 14/01  │  │ │
│  │  └──────┴──────────┴──────────┴─────────┴─────────┘  │ │
│  └──────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

### 5.4 Invoice Form Screen

```
┌────────────────────────────────────────────────────────────┐
│  [حفظ] [طباعة] [PDF]                   فاتورة جديدة ←     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  رقم الفاتورة: INV-2024-0001      التاريخ: 15/01/2024│  │
│  │                                                      │  │
│  │  العميل: [      🔍 بحث عن عميل ▼      ] [+ جديد]   │  │
│  │                                                      │  │
│  │  تاريخ الاستحقاق: [    📅 اختر تاريخ    ]          │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  المنتج: [      🔍 بحث عن منتج ▼      ]  [+ إضافة] │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │ المنتج      │ الكمية │ السعر  │ الخصم │ الإجمالي   │ │
│  ├─────────────┼────────┼────────┼───────┼────────────┤ │
│  │ فلتر زيت    │   2    │  500   │   0   │   1,000   │ │
│  │ بطارية 12V  │   1    │ 1,500  │  100  │   1,400   │ │
│  │                                                      │ │
│  │                           [➕ إضافة منتج]            │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌───────────────────────────────────────┐                │
│  │                    المجموع:  2,400 ج.م │                │
│  │              خصم الفاتورة: [    0    ] │                │
│  │                  الإجمالي:  2,400 ج.م │                │
│  └───────────────────────────────────────┘                │
│                                                            │
│  ملاحظات: [                                              ]│
│                                                            │
│        [إلغاء]                    [💾 حفظ الفاتورة]       │
└────────────────────────────────────────────────────────────┘
```

### 5.5 Payment Dialog

```
┌────────────────────────────────────────┐
│             تسجيل دفعة                 │
├────────────────────────────────────────┤
│                                        │
│  الفاتورة: INV-2024-0001              │
│  العميل: أحمد محمد                     │
│                                        │
│  إجمالي الفاتورة:    2,400 ج.م        │
│  المدفوع سابقاً:     1,000 ج.م        │
│  المتبقي:            1,400 ج.م        │
│                                        │
│  ─────────────────────────────────    │
│                                        │
│  المبلغ: [          ] ج.م             │
│                                        │
│  طريقة الدفع:                          │
│  ◉ كاش                                 │
│  ○ فودافون كاش                         │
│  ○ انستا باي                           │
│                                        │
│  ملاحظات: [                    ]      │
│                                        │
│     [إلغاء]          [✓ تأكيد الدفع]  │
└────────────────────────────────────────┘
```

---

## 6. Features Breakdown

### 6.1 Customers Module (العملاء)

| Feature | Description |
|---------|-------------|
| Add Customer | Name (required), Phone, Address, Company |
| Edit Customer | Update any field |
| Delete Customer | Soft delete (mark inactive) |
| View Balance | Show owed amount and advance payments |
| Customer Statement | All invoices and payments for customer |
| Search | By name, phone, company |

### 6.2 Products Module (المنتجات)

| Feature | Description |
|---------|-------------|
| Add Product | Name, Category, SKU, Brand, Prices, Quantity, Supplier |
| Edit Product | Update any field |
| Delete Product | Soft delete |
| Adjust Stock | Manually add/remove quantity |
| Low Stock Alert | Notify when quantity <= threshold |
| Search | By name, SKU, brand, category |
| Filter | By category, supplier, low stock |

### 6.3 Invoices Module (الفواتير)

| Feature | Description |
|---------|-------------|
| Create Invoice | Select customer, add products, discounts |
| Create Return Invoice | Reverse items and money |
| Add Payment | Partial or full payment |
| Print Invoice | With business logo |
| Export PDF | Save invoice as PDF |
| Invoice Status | Auto-update (Paid, Partial, Unpaid, Overdue) |
| Search | By number, customer, date range |
| Filter | By status, date range |

### 6.4 Reports Module (التقارير)

| Report | Content |
|--------|---------|
| Sales Report | Total sales by period (week/month/year) |
| Profit Report | Sales - Cost = Profit |
| Best Selling | Top products by quantity or revenue |
| Customer Debt | Who owes money, sorted by amount |
| Top Customers | Highest spending customers |
| Stock Report | Current stock with values |
| Low Stock Report | Items below threshold |

### 6.5 Settings Module (الإعدادات)

| Setting | Options |
|---------|---------|
| Business Info | Name, Address, Phone, Logo |
| Users | Add/Edit users, Set permissions |
| Backup | Set folder, Manual backup button |
| Invoice Settings | Number prefix, Starting number |
| Notifications | Enable/Disable types |

---

## 7. User Permissions

### Admin (المدير)
```
✓ All permissions
✓ Manage users
✓ View reports
✓ Change settings
✓ Delete records
✓ View purchase prices and profit
```

### User (مستخدم) - Configurable
```
□ Create invoices
□ Create return invoices
□ Add customers
□ Add products
□ Receive payments
□ View reports
□ Adjust stock
□ View purchase prices
```

---

## 8. Backup System

```
Backup Strategy:
├── Frequency: 4 times daily + on app close
├── Location: User-selected folder or USB
├── Format: SQLite file copy with timestamp
├── Naming: backup_2024-01-15_14-30-00.db
└── Retention: Keep last 30 backups (configurable)

Auto Backup Times:
├── 09:00 AM
├── 12:00 PM
├── 03:00 PM
├── 06:00 PM
└── On Application Close
```

---

## 9. Notifications System

| Type | Trigger | Message Example |
|------|---------|-----------------|
| Low Stock | Quantity <= Threshold | "منتج فلتر زيت وصل للحد الأدنى (1)" |
| Overdue | DueDate < Today & Unpaid | "فاتورة #1042 متأخرة 5 أيام" |
| Due Soon | DueDate = Tomorrow | "فاتورة #1045 تستحق غداً" |
| Negative Stock | Selling with 0 stock | "تحذير: المنتج غير متوفر بالمخزن" |

---

## 10. Invoice Number Format

```
Format: [Prefix]-[Year]-[Sequential Number]

Example: INV-2024-0001

Settings:
├── Prefix: Configurable (default: "INV")
├── Year: Auto from current year
└── Number: Auto-increment, padded to 4 digits
```

---

## 11. Print Layout

```
┌─────────────────────────────────────────┐
│              [BUSINESS LOGO]            │
│           اسم الشركة / المحل            │
│         العنوان - رقم التليفون          │
├─────────────────────────────────────────┤
│                                         │
│  فاتورة رقم: INV-2024-0001             │
│  التاريخ: 15/01/2024                    │
│  العميل: أحمد محمد                      │
│                                         │
├─────────────────────────────────────────┤
│ # │ المنتج      │ الكمية │ السعر │المجموع│
├───┼─────────────┼────────┼───────┼──────┤
│ 1 │ فلتر زيت    │   2    │  500  │1,000 │
│ 2 │ بطارية      │   1    │ 1,500 │1,400 │
├───┴─────────────┴────────┴───────┼──────┤
│                      المجموع الفرعي│2,400 │
│                             الخصم │    0 │
│                           الإجمالي│2,400 │
│                            المدفوع│1,000 │
│                            المتبقي│1,400 │
├─────────────────────────────────────────┤
│  تاريخ الاستحقاق: 30/01/2024           │
│  ملاحظات: سيتم الاستلام يوم السبت       │
├─────────────────────────────────────────┤
│              شكراً لتعاملكم             │
└─────────────────────────────────────────┘
```

---

## 12. Development Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup
- [ ] Database design and creation
- [ ] Basic UI layout with RTL
- [ ] Navigation system

### Phase 2: Core Modules (Week 3-5)
- [ ] Categories CRUD
- [ ] Suppliers CRUD
- [ ] Products CRUD with stock
- [ ] Customers CRUD

### Phase 3: Invoicing (Week 6-8)
- [ ] Invoice creation
- [ ] Return invoices
- [ ] Payment system
- [ ] Customer balance logic
- [ ] Print and PDF export

### Phase 4: Advanced Features (Week 9-10)
- [ ] Dashboard
- [ ] Notifications system
- [ ] Reports
- [ ] Search with dropdown

### Phase 5: Final (Week 11-12)
- [ ] User management
- [ ] Backup system
- [ ] Settings
- [ ] Testing
- [ ] Bug fixes