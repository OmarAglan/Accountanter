import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Badge } from "./ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { DataTable } from "./DataTable";
import { toast } from "sonner@2.0.3";
import {
  Plus,
  Search,
  Filter,
  Download,
  Upload,
  Receipt,
  Calendar,
  DollarSign,
  Tag,
  Building,
  Car,
  Utensils,
  Laptop,
  Plane,
  MoreHorizontal,
  Trash2,
  Edit,
  Eye,
  FileImage,
} from "lucide-react";

interface ExpensesProps {
  onCreateExpense?: () => void;
}

interface Expense {
  id: string;
  date: string;
  description: string;
  amount: number;
  category: string;
  vendor: string;
  paymentMethod: string;
  status: "pending" | "approved" | "rejected";
  receipt?: boolean;
  project?: string;
  tags: string[];
}

const sampleExpenses: Expense[] = [
  {
    id: "EXP-001",
    date: "2024-01-15",
    description: "Office supplies and stationery",
    amount: 125.50,
    category: "Office Supplies",
    vendor: "Office Depot",
    paymentMethod: "Company Credit Card",
    status: "approved",
    receipt: true,
    project: "General Operations",
    tags: ["supplies", "office"],
  },
  {
    id: "EXP-002",
    date: "2024-01-14",
    description: "Client lunch meeting",
    amount: 85.00,
    category: "Meals & Entertainment",
    vendor: "The Plaza Restaurant",
    paymentMethod: "Cash",
    status: "pending",
    receipt: true,
    project: "Client Development",
    tags: ["meals", "client"],
  },
  {
    id: "EXP-003",
    date: "2024-01-12",
    description: "Software subscription renewal",
    amount: 299.00,
    category: "Software",
    vendor: "Adobe Systems",
    paymentMethod: "Bank Transfer",
    status: "approved",
    receipt: false,
    project: "Design Tools",
    tags: ["software", "subscription"],
  },
  {
    id: "EXP-004",
    date: "2024-01-10",
    description: "Travel to conference",
    amount: 850.00,
    category: "Travel",
    vendor: "American Airlines",
    paymentMethod: "Company Credit Card",
    status: "approved",
    receipt: true,
    project: "Professional Development",
    tags: ["travel", "conference"],
  },
  {
    id: "EXP-005",
    date: "2024-01-08",
    description: "New laptop for developer",
    amount: 2499.00,
    category: "Equipment",
    vendor: "Apple Store",
    paymentMethod: "Purchase Order",
    status: "pending",
    receipt: true,
    project: "IT Equipment",
    tags: ["equipment", "laptop"],
  },
];

const expenseCategories = [
  "Office Supplies",
  "Software",
  "Equipment",
  "Travel",
  "Meals & Entertainment",
  "Marketing",
  "Professional Services",
  "Utilities",
  "Rent",
  "Insurance",
  "Training",
  "Other",
];

const paymentMethods = [
  "Cash",
  "Company Credit Card",
  "Personal Credit Card",
  "Bank Transfer",
  "Check",
  "Purchase Order",
];

export function Expenses({ onCreateExpense }: ExpensesProps) {
  const [expenses, setExpenses] = useState<Expense[]>(sampleExpenses);
  const [showAddExpense, setShowAddExpense] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [activeTab, setActiveTab] = useState("list");

  const [newExpense, setNewExpense] = useState({
    description: "",
    amount: "",
    category: "",
    vendor: "",
    paymentMethod: "",
    date: new Date().toISOString().split('T')[0],
    project: "",
    tags: "",
    receipt: false,
  });

  const filteredExpenses = expenses.filter((expense) => {
    const matchesSearch = expense.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         expense.vendor.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategory === "all" || expense.category === selectedCategory;
    const matchesStatus = selectedStatus === "all" || expense.status === selectedStatus;
    
    return matchesSearch && matchesCategory && matchesStatus;
  });

  const totalExpenses = expenses.reduce((sum, expense) => sum + expense.amount, 0);
  const pendingExpenses = expenses.filter(e => e.status === "pending").reduce((sum, expense) => sum + expense.amount, 0);
  const approvedExpenses = expenses.filter(e => e.status === "approved").reduce((sum, expense) => sum + expense.amount, 0);

  const handleAddExpense = () => {
    if (!newExpense.description || !newExpense.amount || !newExpense.category) {
      toast.error("Please fill in all required fields");
      return;
    }

    const expense: Expense = {
      id: `EXP-${String(expenses.length + 1).padStart(3, '0')}`,
      description: newExpense.description,
      amount: parseFloat(newExpense.amount),
      category: newExpense.category,
      vendor: newExpense.vendor,
      paymentMethod: newExpense.paymentMethod,
      date: newExpense.date,
      status: "pending",
      receipt: newExpense.receipt,
      project: newExpense.project || undefined,
      tags: newExpense.tags ? newExpense.tags.split(',').map(tag => tag.trim()) : [],
    };

    setExpenses([expense, ...expenses]);
    setNewExpense({
      description: "",
      amount: "",
      category: "",
      vendor: "",
      paymentMethod: "",
      date: new Date().toISOString().split('T')[0],
      project: "",
      tags: "",
      receipt: false,
    });
    setShowAddExpense(false);
    toast.success("Expense added successfully");
  };

  const handleApproveExpense = (id: string) => {
    setExpenses(expenses.map(expense => 
      expense.id === id ? { ...expense, status: "approved" as const } : expense
    ));
    toast.success("Expense approved");
  };

  const handleRejectExpense = (id: string) => {
    setExpenses(expenses.map(expense => 
      expense.id === id ? { ...expense, status: "rejected" as const } : expense
    ));
    toast.error("Expense rejected");
  };

  const handleDeleteExpense = (id: string) => {
    setExpenses(expenses.filter(expense => expense.id !== id));
    toast.success("Expense deleted");
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case "Office Supplies": return <Building className="h-4 w-4" />;
      case "Travel": return <Plane className="h-4 w-4" />;
      case "Meals & Entertainment": return <Utensils className="h-4 w-4" />;
      case "Equipment": return <Laptop className="h-4 w-4" />;
      case "Software": return <Laptop className="h-4 w-4" />;
      default: return <Tag className="h-4 w-4" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "approved": return "success";
      case "pending": return "warning";
      case "rejected": return "destructive";
      default: return "secondary";
    }
  };

  const expenseColumns = [
    {
      accessorKey: "date",
      header: "Date",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("date"));
        return date.toLocaleDateString();
      },
    },
    {
      accessorKey: "description",
      header: "Description",
      cell: ({ row }: any) => {
        const expense = row.original;
        return (
          <div className="flex items-center gap-2">
            {getCategoryIcon(expense.category)}
            <div>
              <div className="font-medium">{expense.description}</div>
              <div className="text-sm text-muted-foreground">{expense.vendor}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "category",
      header: "Category",
    },
    {
      accessorKey: "amount",
      header: "Amount",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("amount"));
        return <span className="financial-amount">${amount.toFixed(2)}</span>;
      },
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }: any) => {
        const status = row.getValue("status");
        return (
          <Badge variant={getStatusColor(status as string) as any}>
            {status}
          </Badge>
        );
      },
    },
    {
      accessorKey: "receipt",
      header: "Receipt",
      cell: ({ row }: any) => {
        const hasReceipt = row.getValue("receipt");
        return hasReceipt ? (
          <Receipt className="h-4 w-4 text-success" />
        ) : (
          <div className="w-4 h-4" />
        );
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const expense = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm">
              <Eye className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Edit className="h-4 w-4" />
            </Button>
            {expense.status === "pending" && (
              <>
                <Button 
                  variant="ghost" 
                  size="sm"
                  onClick={() => handleApproveExpense(expense.id)}
                  className="text-success hover:text-success"
                >
                  ✓
                </Button>
                <Button 
                  variant="ghost" 
                  size="sm"
                  onClick={() => handleRejectExpense(expense.id)}
                  className="text-destructive hover:text-destructive"
                >
                  ✗
                </Button>
              </>
            )}
            <Button 
              variant="ghost" 
              size="sm"
              onClick={() => handleDeleteExpense(expense.id)}
              className="text-destructive hover:text-destructive"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Expense Management</h1>
          <p className="text-muted-foreground">
            Track and manage your business expenses efficiently.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline">
            <Upload className="h-4 w-4 mr-2" />
            Import
          </Button>
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
          <Dialog open={showAddExpense} onOpenChange={setShowAddExpense}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Add Expense
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Add New Expense</DialogTitle>
                <DialogDescription>
                  Enter the details of your business expense below.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="description">Description *</Label>
                    <Input
                      id="description"
                      placeholder="What was this expense for?"
                      value={newExpense.description}
                      onChange={(e) => setNewExpense(prev => ({ ...prev, description: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="amount">Amount *</Label>
                    <Input
                      id="amount"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      value={newExpense.amount}
                      onChange={(e) => setNewExpense(prev => ({ ...prev, amount: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="category">Category *</Label>
                    <Select value={newExpense.category} onValueChange={(value) => setNewExpense(prev => ({ ...prev, category: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select category" />
                      </SelectTrigger>
                      <SelectContent>
                        {expenseCategories.map((category) => (
                          <SelectItem key={category} value={category}>
                            {category}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="vendor">Vendor</Label>
                    <Input
                      id="vendor"
                      placeholder="Who did you pay?"
                      value={newExpense.vendor}
                      onChange={(e) => setNewExpense(prev => ({ ...prev, vendor: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="paymentMethod">Payment Method</Label>
                    <Select value={newExpense.paymentMethod} onValueChange={(value) => setNewExpense(prev => ({ ...prev, paymentMethod: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select payment method" />
                      </SelectTrigger>
                      <SelectContent>
                        {paymentMethods.map((method) => (
                          <SelectItem key={method} value={method}>
                            {method}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="date">Date</Label>
                    <Input
                      id="date"
                      type="date"
                      value={newExpense.date}
                      onChange={(e) => setNewExpense(prev => ({ ...prev, date: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="project">Project (Optional)</Label>
                  <Input
                    id="project"
                    placeholder="Associate with a project"
                    value={newExpense.project}
                    onChange={(e) => setNewExpense(prev => ({ ...prev, project: e.target.value }))}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="tags">Tags (Optional)</Label>
                  <Input
                    id="tags"
                    placeholder="Comma-separated tags"
                    value={newExpense.tags}
                    onChange={(e) => setNewExpense(prev => ({ ...prev, tags: e.target.value }))}
                  />
                </div>

                <div className="flex items-center gap-3">
                  <Button variant="outline" className="flex-1">
                    <FileImage className="h-4 w-4 mr-2" />
                    Upload Receipt
                  </Button>
                  <span className="text-sm text-muted-foreground">Optional but recommended</span>
                </div>

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowAddExpense(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddExpense}>
                    Add Expense
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Total Expenses</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold financial-amount">${totalExpenses.toFixed(2)}</div>
            <p className="text-sm text-muted-foreground">This month</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Pending Approval</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold financial-amount text-warning">${pendingExpenses.toFixed(2)}</div>
            <p className="text-sm text-muted-foreground">{expenses.filter(e => e.status === "pending").length} expenses</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Approved</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold financial-amount text-success">${approvedExpenses.toFixed(2)}</div>
            <p className="text-sm text-muted-foreground">{expenses.filter(e => e.status === "approved").length} expenses</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">Average Expense</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold financial-amount">${(totalExpenses / expenses.length).toFixed(2)}</div>
            <p className="text-sm text-muted-foreground">Per expense</p>
          </CardContent>
        </Card>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList>
          <TabsTrigger value="list">Expense List</TabsTrigger>
          <TabsTrigger value="categories">By Category</TabsTrigger>
          <TabsTrigger value="pending">Pending Approval</TabsTrigger>
        </TabsList>

        <TabsContent value="list" className="space-y-6">
          {/* Filters */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search expenses..."
                      className="pl-10"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                    />
                  </div>
                </div>
                <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Categories" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Categories</SelectItem>
                    {expenseCategories.map((category) => (
                      <SelectItem key={category} value={category}>
                        {category}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="pending">Pending</SelectItem>
                    <SelectItem value="approved">Approved</SelectItem>
                    <SelectItem value="rejected">Rejected</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Expenses Table */}
          <Card>
            <CardHeader>
              <CardTitle>Expenses</CardTitle>
              <CardDescription>
                {filteredExpenses.length} of {expenses.length} expenses
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={expenseColumns}
                data={filteredExpenses}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="categories" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Expenses by Category</CardTitle>
              <CardDescription>
                Breakdown of expenses across different categories
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {expenseCategories.map((category) => {
                  const categoryExpenses = expenses.filter(e => e.category === category);
                  const categoryTotal = categoryExpenses.reduce((sum, e) => sum + e.amount, 0);
                  const percentage = totalExpenses > 0 ? (categoryTotal / totalExpenses) * 100 : 0;
                  
                  if (categoryTotal === 0) return null;
                  
                  return (
                    <div key={category} className="flex items-center justify-between p-3 border rounded-lg">
                      <div className="flex items-center gap-3">
                        {getCategoryIcon(category)}
                        <div>
                          <div className="font-medium">{category}</div>
                          <div className="text-sm text-muted-foreground">
                            {categoryExpenses.length} expenses
                          </div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-medium financial-amount">
                          ${categoryTotal.toFixed(2)}
                        </div>
                        <div className="text-sm text-muted-foreground">
                          {percentage.toFixed(1)}%
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="pending" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Pending Approval</CardTitle>
              <CardDescription>
                Expenses waiting for approval ({expenses.filter(e => e.status === "pending").length} items)
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {expenses.filter(e => e.status === "pending").map((expense) => (
                  <div key={expense.id} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center gap-4">
                      {getCategoryIcon(expense.category)}
                      <div>
                        <div className="font-medium">{expense.description}</div>
                        <div className="text-sm text-muted-foreground">
                          {expense.vendor} • {new Date(expense.date).toLocaleDateString()}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="text-right">
                        <div className="font-medium financial-amount">
                          ${expense.amount.toFixed(2)}
                        </div>
                        <div className="text-sm text-muted-foreground">
                          {expense.category}
                        </div>
                      </div>
                      <div className="flex gap-2">
                        <Button 
                          size="sm"
                          onClick={() => handleApproveExpense(expense.id)}
                          className="bg-success hover:bg-success/90"
                        >
                          Approve
                        </Button>
                        <Button 
                          size="sm" 
                          variant="destructive"
                          onClick={() => handleRejectExpense(expense.id)}
                        >
                          Reject
                        </Button>
                      </div>
                    </div>
                  </div>
                ))}
                {expenses.filter(e => e.status === "pending").length === 0 && (
                  <div className="text-center py-8 text-muted-foreground">
                    No expenses pending approval
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}