import { useState } from "react";
import { DataTable } from "./DataTable";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Plus, Search, Filter, AlertTriangle, Package } from "lucide-react";
import { Badge } from "./ui/badge";
import { Alert, AlertDescription } from "./ui/alert";

export function Inventory() {
  const [searchTerm, setSearchTerm] = useState("");

  const inventoryData = [
    {
      id: "PRD-001",
      name: "Wireless Headphones",
      sku: "WH-001",
      category: "Electronics",
      quantity: 25,
      minStock: 10,
      unitPrice: 99.99,
      totalValue: 2499.75,
      status: "In Stock",
      supplier: "TechCorp",
    },
    {
      id: "PRD-002",
      name: "Laptop Stand",
      sku: "LS-002",
      category: "Accessories",
      quantity: 5,
      minStock: 8,
      unitPrice: 49.99,
      totalValue: 249.95,
      status: "Low Stock",
      supplier: "OfficeSupply Co",
    },
    {
      id: "PRD-003",
      name: "Mechanical Keyboard",
      sku: "KB-003",
      category: "Electronics",
      quantity: 18,
      minStock: 5,
      unitPrice: 129.99,
      totalValue: 2339.82,
      status: "In Stock",
      supplier: "TechCorp",
    },
    {
      id: "PRD-004",
      name: "USB Cable",
      sku: "UC-004",
      category: "Accessories",
      quantity: 0,
      minStock: 20,
      unitPrice: 12.99,
      totalValue: 0,
      status: "Out of Stock",
      supplier: "CableTech",
    },
    {
      id: "PRD-005",
      name: "Monitor",
      sku: "MN-005",
      category: "Electronics",
      quantity: 12,
      minStock: 3,
      unitPrice: 299.99,
      totalValue: 3599.88,
      status: "In Stock",
      supplier: "DisplayTech",
    },
  ];

  const inventoryColumns = [
    { key: "name", label: "Product Name" },
    { key: "sku", label: "SKU" },
    { key: "category", label: "Category" },
    { key: "quantity", label: "Quantity", align: "center" as const },
    { key: "unitPrice", label: "Unit Price", type: "currency" as const, align: "right" as const },
    { key: "totalValue", label: "Total Value", type: "currency" as const, align: "right" as const },
    { key: "status", label: "Status", type: "status" as const },
    { key: "actions", label: "Actions", type: "actions" as const, align: "center" as const },
  ];

  const filteredInventory = inventoryData.filter(item =>
    item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.sku.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.category.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const lowStockItems = inventoryData.filter(item => 
    item.quantity <= item.minStock && item.quantity > 0
  );

  const outOfStockItems = inventoryData.filter(item => item.quantity === 0);

  const totalInventoryValue = inventoryData.reduce((sum, item) => sum + item.totalValue, 0);
  const totalProducts = inventoryData.length;
  const categoryCounts = inventoryData.reduce((acc, item) => {
    acc[item.category] = (acc[item.category] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="tracking-tight">Inventory</h1>
          <p className="text-muted-foreground">
            Manage your product inventory and stock levels.
          </p>
        </div>
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Add Product
        </Button>
      </div>

      {/* Alerts for Low Stock and Out of Stock */}
      {(lowStockItems.length > 0 || outOfStockItems.length > 0) && (
        <div className="space-y-3">
          {outOfStockItems.length > 0 && (
            <Alert className="border-destructive">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                <strong>{outOfStockItems.length} product(s) are out of stock:</strong>{" "}
                {outOfStockItems.map(item => item.name).join(", ")}
              </AlertDescription>
            </Alert>
          )}
          {lowStockItems.length > 0 && (
            <Alert className="border-warning">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                <strong>{lowStockItems.length} product(s) are running low:</strong>{" "}
                {lowStockItems.map(item => item.name).join(", ")}
              </AlertDescription>
            </Alert>
          )}
        </div>
      )}

      {/* Inventory Summary */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-primary/10 p-3 rounded-lg">
                <Package className="h-6 w-6 text-primary" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold">
                  {totalProducts}
                </div>
                <p className="text-sm text-muted-foreground">Total Products</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-profit/10 p-3 rounded-lg">
                <Package className="h-6 w-6 text-profit" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold text-profit">
                  ${totalInventoryValue.toLocaleString()}
                </div>
                <p className="text-sm text-muted-foreground">Total Value</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-warning/10 p-3 rounded-lg">
                <AlertTriangle className="h-6 w-6 text-warning" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold text-warning">
                  {lowStockItems.length}
                </div>
                <p className="text-sm text-muted-foreground">Low Stock</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-destructive/10 p-3 rounded-lg">
                <AlertTriangle className="h-6 w-6 text-destructive" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold text-destructive">
                  {outOfStockItems.length}
                </div>
                <p className="text-sm text-muted-foreground">Out of Stock</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Categories Overview */}
      <Card>
        <CardHeader>
          <CardTitle>Categories</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {Object.entries(categoryCounts).map(([category, count]) => (
              <Badge key={category} variant="secondary" className="px-3 py-1">
                {category} ({count})
              </Badge>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Search and Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search products by name, SKU, or category..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <Button variant="outline">
              <Filter className="mr-2 h-4 w-4" />
              Filter
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Inventory Table */}
      <Card>
        <CardHeader>
          <CardTitle>Product Inventory</CardTitle>
        </CardHeader>
        <CardContent>
          <DataTable
            columns={inventoryColumns}
            data={filteredInventory}
            onRowAction={(action, row) => {
              console.log(`Action: ${action}`, row);
            }}
          />
        </CardContent>
      </Card>
    </div>
  );
}