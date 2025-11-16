import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Badge } from "./ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "./ui/dialog";
import { DataTable } from "./DataTable";
import { Switch } from "./ui/switch";
import { Progress } from "./ui/progress";
import { toast } from "sonner@2.0.3";
import {
  Plus,
  Search,
  Download,
  Calculator,
  FileText,
  AlertCircle,
  CheckCircle,
  Calendar,
  TrendingUp,
  DollarSign,
  Percent,
  Building,
  MapPin,
  Globe,
  Settings,
  Trash2,
  Edit,
  Eye,
} from "lucide-react";

interface TaxManagementProps {
  onGenerateReport?: () => void;
}

interface TaxRate {
  id: string;
  name: string;
  type: "sales" | "income" | "vat" | "gst" | "custom";
  rate: number;
  jurisdiction: string;
  applicableFrom: string;
  applicableTo?: string;
  status: "active" | "inactive";
  description: string;
  compoundable: boolean;
}

interface TaxTransaction {
  id: string;
  date: string;
  type: "invoice" | "expense" | "payment";
  description: string;
  amount: number;
  taxAmount: number;
  taxRate: number;
  taxType: string;
  jurisdiction: string;
  reference: string;
  status: "calculated" | "paid" | "pending";
}

interface TaxPeriod {
  id: string;
  period: string;
  startDate: string;
  endDate: string;
  totalRevenue: number;
  totalTaxCollected: number;
  totalTaxPaid: number;
  netTaxLiability: number;
  status: "open" | "filed" | "paid" | "overdue";
  dueDate: string;
}

const sampleTaxRates: TaxRate[] = [
  {
    id: "TAX-001",
    name: "Sales Tax (NY)",
    type: "sales",
    rate: 8.25,
    jurisdiction: "New York, NY",
    applicableFrom: "2024-01-01",
    status: "active",
    description: "New York State and local sales tax",
    compoundable: false,
  },
  {
    id: "TAX-002",
    name: "VAT Standard Rate",
    type: "vat",
    rate: 20.0,
    jurisdiction: "United Kingdom",
    applicableFrom: "2024-01-01",
    status: "active",
    description: "UK VAT standard rate",
    compoundable: false,
  },
  {
    id: "TAX-003",
    name: "GST (Canada)",
    type: "gst",
    rate: 5.0,
    jurisdiction: "Canada",
    applicableFrom: "2024-01-01",
    status: "active",
    description: "Canadian Goods and Services Tax",
    compoundable: true,
  },
  {
    id: "TAX-004",
    name: "Income Tax Withholding",
    type: "income",
    rate: 24.0,
    jurisdiction: "Federal",
    applicableFrom: "2024-01-01",
    status: "active",
    description: "Federal income tax withholding",
    compoundable: false,
  },
];

const sampleTaxTransactions: TaxTransaction[] = [
  {
    id: "TXN-001",
    date: "2024-01-15",
    type: "invoice",
    description: "Software Development Services - Acme Corp",
    amount: 2500.00,
    taxAmount: 206.25,
    taxRate: 8.25,
    taxType: "Sales Tax (NY)",
    jurisdiction: "New York, NY",
    reference: "INV-2024-001",
    status: "calculated",
  },
  {
    id: "TXN-002",
    date: "2024-01-12",
    type: "invoice",
    description: "Consulting Services - TechStart Inc",
    amount: 1750.00,
    taxAmount: 350.00,
    taxRate: 20.0,
    taxType: "VAT Standard Rate",
    jurisdiction: "United Kingdom",
    reference: "INV-2024-002",
    status: "paid",
  },
  {
    id: "TXN-003",
    date: "2024-01-10",
    type: "expense",
    description: "Office Equipment Purchase",
    amount: 850.00,
    taxAmount: 42.50,
    taxRate: 5.0,
    taxType: "GST (Canada)",
    jurisdiction: "Canada",
    reference: "EXP-2024-003",
    status: "calculated",
  },
];

const sampleTaxPeriods: TaxPeriod[] = [
  {
    id: "PER-001",
    period: "Q4 2023",
    startDate: "2023-10-01",
    endDate: "2023-12-31",
    totalRevenue: 125000.00,
    totalTaxCollected: 10312.50,
    totalTaxPaid: 2150.00,
    netTaxLiability: 8162.50,
    status: "paid",
    dueDate: "2024-01-31",
  },
  {
    id: "PER-002",
    period: "Q1 2024",
    startDate: "2024-01-01",
    endDate: "2024-03-31",
    totalRevenue: 89500.00,
    totalTaxCollected: 7383.75,
    totalTaxPaid: 1890.00,
    netTaxLiability: 5493.75,
    status: "filed",
    dueDate: "2024-04-30",
  },
  {
    id: "PER-003",
    period: "Q2 2024",
    startDate: "2024-04-01",
    endDate: "2024-06-30",
    totalRevenue: 95000.00,
    totalTaxCollected: 7837.50,
    totalTaxPaid: 2100.00,
    netTaxLiability: 5737.50,
    status: "open",
    dueDate: "2024-07-31",
  },
];

export function TaxManagement({ onGenerateReport }: TaxManagementProps) {
  const [taxRates, setTaxRates] = useState<TaxRate[]>(sampleTaxRates);
  const [taxTransactions, setTaxTransactions] = useState<TaxTransaction[]>(sampleTaxTransactions);
  const [taxPeriods, setTaxPeriods] = useState<TaxPeriod[]>(sampleTaxPeriods);
  const [showAddTaxRate, setShowAddTaxRate] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedType, setSelectedType] = useState("all");
  const [selectedJurisdiction, setSelectedJurisdiction] = useState("all");
  const [activeTab, setActiveTab] = useState("overview");

  const [newTaxRate, setNewTaxRate] = useState({
    name: "",
    type: "",
    rate: "",
    jurisdiction: "",
    applicableFrom: new Date().toISOString().split('T')[0],
    description: "",
    compoundable: false,
  });

  const filteredTransactions = taxTransactions.filter((transaction) => {
    const matchesSearch = transaction.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         transaction.reference.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = selectedType === "all" || transaction.type === selectedType;
    const matchesJurisdiction = selectedJurisdiction === "all" || transaction.jurisdiction === selectedJurisdiction;
    
    return matchesSearch && matchesType && matchesJurisdiction;
  });

  const totalTaxCollected = taxTransactions
    .filter(t => t.type === "invoice" && t.status !== "pending")
    .reduce((sum, t) => sum + t.taxAmount, 0);
  const totalTaxPaid = taxTransactions
    .filter(t => t.type === "expense" && t.status !== "pending")
    .reduce((sum, t) => sum + t.taxAmount, 0);
  const netTaxLiability = totalTaxCollected - totalTaxPaid;
  const currentPeriod = taxPeriods.find(p => p.status === "open");

  const handleAddTaxRate = () => {
    if (!newTaxRate.name || !newTaxRate.type || !newTaxRate.rate || !newTaxRate.jurisdiction) {
      toast.error("Please fill in all required fields");
      return;
    }

    const taxRate: TaxRate = {
      id: `TAX-${String(taxRates.length + 1).padStart(3, '0')}`,
      name: newTaxRate.name,
      type: newTaxRate.type as any,
      rate: parseFloat(newTaxRate.rate),
      jurisdiction: newTaxRate.jurisdiction,
      applicableFrom: newTaxRate.applicableFrom,
      status: "active",
      description: newTaxRate.description,
      compoundable: newTaxRate.compoundable,
    };

    setTaxRates([taxRate, ...taxRates]);
    setNewTaxRate({
      name: "",
      type: "",
      rate: "",
      jurisdiction: "",
      applicableFrom: new Date().toISOString().split('T')[0],
      description: "",
      compoundable: false,
    });
    setShowAddTaxRate(false);
    toast.success("Tax rate added successfully");
  };

  const handleCalculateTax = (amount: number, taxRateId: string) => {
    const taxRate = taxRates.find(r => r.id === taxRateId);
    if (taxRate) {
      return (amount * taxRate.rate) / 100;
    }
    return 0;
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "sales": return <DollarSign className="h-4 w-4" />;
      case "income": return <Building className="h-4 w-4" />;
      case "vat": return <Globe className="h-4 w-4" />;
      case "gst": return <MapPin className="h-4 w-4" />;
      default: return <Percent className="h-4 w-4" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active": return "success";
      case "inactive": return "secondary";
      case "calculated": return "warning";
      case "paid": return "success";
      case "pending": return "secondary";
      case "filed": return "info";
      case "open": return "warning";
      case "overdue": return "destructive";
      default: return "secondary";
    }
  };

  const taxRateColumns = [
    {
      accessorKey: "name",
      header: "Tax Rate",
      cell: ({ row }: any) => {
        const taxRate = row.original;
        return (
          <div className="flex items-center gap-2">
            {getTypeIcon(taxRate.type)}
            <div>
              <div className="font-medium">{taxRate.name}</div>
              <div className="text-sm text-muted-foreground capitalize">{taxRate.type}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "rate",
      header: "Rate",
      cell: ({ row }: any) => {
        const rate = parseFloat(row.getValue("rate"));
        return <span className="font-medium">{rate}%</span>;
      },
    },
    {
      accessorKey: "jurisdiction",
      header: "Jurisdiction",
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
      accessorKey: "applicableFrom",
      header: "Effective From",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("applicableFrom"));
        return date.toLocaleDateString();
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const taxRate = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm">
              <Eye className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Edit className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm" className="text-destructive hover:text-destructive">
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        );
      },
    },
  ];

  const transactionColumns = [
    {
      accessorKey: "date",
      header: "Date",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("date"));
        return date.toLocaleDateString();
      },
    },
    {
      accessorKey: "reference",
      header: "Reference",
      cell: ({ row }: any) => {
        const transaction = row.original;
        return (
          <div className="flex items-center gap-2">
            <FileText className="h-4 w-4 text-muted-foreground" />
            <div>
              <div className="font-medium">{transaction.reference}</div>
              <div className="text-sm text-muted-foreground capitalize">{transaction.type}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "description",
      header: "Description",
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
      accessorKey: "taxAmount",
      header: "Tax",
      cell: ({ row }: any) => {
        const taxAmount = parseFloat(row.getValue("taxAmount"));
        const transaction = row.original;
        return (
          <div>
            <div className="financial-amount font-medium">${taxAmount.toFixed(2)}</div>
            <div className="text-sm text-muted-foreground">{transaction.taxRate}%</div>
          </div>
        );
      },
    },
    {
      accessorKey: "jurisdiction",
      header: "Jurisdiction",
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
  ];

  const periodColumns = [
    {
      accessorKey: "period",
      header: "Period",
      cell: ({ row }: any) => {
        const period = row.original;
        return (
          <div>
            <div className="font-medium">{period.period}</div>
            <div className="text-sm text-muted-foreground">
              {new Date(period.startDate).toLocaleDateString()} - {new Date(period.endDate).toLocaleDateString()}
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "totalRevenue",
      header: "Revenue",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("totalRevenue"));
        return <span className="financial-amount">${amount.toFixed(2)}</span>;
      },
    },
    {
      accessorKey: "totalTaxCollected",
      header: "Tax Collected",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("totalTaxCollected"));
        return <span className="financial-amount text-success">${amount.toFixed(2)}</span>;
      },
    },
    {
      accessorKey: "totalTaxPaid",
      header: "Tax Paid",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("totalTaxPaid"));
        return <span className="financial-amount text-destructive">${amount.toFixed(2)}</span>;
      },
    },
    {
      accessorKey: "netTaxLiability",
      header: "Net Liability",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("netTaxLiability"));
        return <span className="financial-amount font-medium">${amount.toFixed(2)}</span>;
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
      accessorKey: "dueDate",
      header: "Due Date",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("dueDate"));
        const isOverdue = date < new Date();
        return (
          <div className={isOverdue ? "text-destructive" : ""}>
            {date.toLocaleDateString()}
          </div>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Tax Management</h1>
          <p className="text-muted-foreground">
            Manage tax rates, calculate obligations, and generate compliance reports.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export Reports
          </Button>
          <Dialog open={showAddTaxRate} onOpenChange={setShowAddTaxRate}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Add Tax Rate
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Add Tax Rate</DialogTitle>
                <DialogDescription>
                  Configure a new tax rate for your business operations.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Tax Name *</Label>
                    <Input
                      id="name"
                      placeholder="Sales Tax (NY)"
                      value={newTaxRate.name}
                      onChange={(e) => setNewTaxRate(prev => ({ ...prev, name: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="type">Tax Type *</Label>
                    <Select value={newTaxRate.type} onValueChange={(value) => setNewTaxRate(prev => ({ ...prev, type: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select tax type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="sales">Sales Tax</SelectItem>
                        <SelectItem value="income">Income Tax</SelectItem>
                        <SelectItem value="vat">VAT</SelectItem>
                        <SelectItem value="gst">GST</SelectItem>
                        <SelectItem value="custom">Custom</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="rate">Tax Rate (%) *</Label>
                    <Input
                      id="rate"
                      type="number"
                      step="0.01"
                      placeholder="8.25"
                      value={newTaxRate.rate}
                      onChange={(e) => setNewTaxRate(prev => ({ ...prev, rate: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="jurisdiction">Jurisdiction *</Label>
                    <Input
                      id="jurisdiction"
                      placeholder="New York, NY"
                      value={newTaxRate.jurisdiction}
                      onChange={(e) => setNewTaxRate(prev => ({ ...prev, jurisdiction: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="applicableFrom">Effective From *</Label>
                  <Input
                    id="applicableFrom"
                    type="date"
                    value={newTaxRate.applicableFrom}
                    onChange={(e) => setNewTaxRate(prev => ({ ...prev, applicableFrom: e.target.value }))}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Description</Label>
                  <Input
                    id="description"
                    placeholder="New York State and local sales tax"
                    value={newTaxRate.description}
                    onChange={(e) => setNewTaxRate(prev => ({ ...prev, description: e.target.value }))}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <Label>Compoundable Tax</Label>
                    <p className="text-sm text-muted-foreground">
                      Can this tax be calculated on top of other taxes?
                    </p>
                  </div>
                  <Switch
                    checked={newTaxRate.compoundable}
                    onCheckedChange={(checked) => setNewTaxRate(prev => ({ ...prev, compoundable: checked }))}
                  />
                </div>

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowAddTaxRate(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddTaxRate}>
                    Add Tax Rate
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="rates">Tax Rates</TabsTrigger>
          <TabsTrigger value="transactions">Transactions</TabsTrigger>
          <TabsTrigger value="periods">Tax Periods</TabsTrigger>
          <TabsTrigger value="calculator">Calculator</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <TrendingUp className="h-4 w-4" />
                  Tax Collected
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount text-success">${totalTaxCollected.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">This period</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  Tax Paid
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount text-destructive">${totalTaxPaid.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">This period</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Calculator className="h-4 w-4" />
                  Net Liability
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className={`text-2xl font-bold financial-amount ${netTaxLiability >= 0 ? 'text-warning' : 'text-success'}`}>
                  ${Math.abs(netTaxLiability).toFixed(2)}
                </div>
                <p className="text-sm text-muted-foreground">
                  {netTaxLiability >= 0 ? 'Owed' : 'Refund due'}
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  Next Filing
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {currentPeriod ? new Date(currentPeriod.dueDate).toLocaleDateString() : "N/A"}
                </div>
                <p className="text-sm text-muted-foreground">
                  {currentPeriod ? currentPeriod.period : "No open periods"}
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Current Period Status */}
          {currentPeriod && (
            <Card>
              <CardHeader>
                <CardTitle>Current Tax Period: {currentPeriod.period}</CardTitle>
                <CardDescription>
                  {new Date(currentPeriod.startDate).toLocaleDateString()} - {new Date(currentPeriod.endDate).toLocaleDateString()}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm">Revenue</span>
                      <span className="financial-amount">${currentPeriod.totalRevenue.toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm">Tax Collected</span>
                      <span className="financial-amount text-success">${currentPeriod.totalTaxCollected.toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm">Tax Paid</span>
                      <span className="financial-amount text-destructive">${currentPeriod.totalTaxPaid.toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between font-medium pt-2 border-t">
                      <span>Net Liability</span>
                      <span className="financial-amount">${currentPeriod.netTaxLiability.toFixed(2)}</span>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Filing Progress</span>
                      <span className="text-sm text-muted-foreground">65%</span>
                    </div>
                    <Progress value={65} className="h-2" />
                    <p className="text-sm text-muted-foreground">
                      Due: {new Date(currentPeriod.dueDate).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="space-y-2">
                    <Button className="w-full">
                      <FileText className="h-4 w-4 mr-2" />
                      Prepare Filing
                    </Button>
                    <Button variant="outline" className="w-full">
                      <Calculator className="h-4 w-4 mr-2" />
                      Review Calculations
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Tax Compliance Alerts */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <AlertCircle className="h-5 w-5 text-warning" />
                Compliance Alerts
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 border rounded-lg">
                  <div className="flex items-center gap-3">
                    <AlertCircle className="h-4 w-4 text-warning" />
                    <div>
                      <p className="font-medium">Q2 2024 Filing Due Soon</p>
                      <p className="text-sm text-muted-foreground">Due date: July 31, 2024</p>
                    </div>
                  </div>
                  <Button size="sm">Review</Button>
                </div>
                <div className="flex items-center justify-between p-3 border rounded-lg">
                  <div className="flex items-center gap-3">
                    <CheckCircle className="h-4 w-4 text-success" />
                    <div>
                      <p className="font-medium">All Tax Rates Updated</p>
                      <p className="text-sm text-muted-foreground">Last updated: January 1, 2024</p>
                    </div>
                  </div>
                  <Badge variant="success">Current</Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="rates" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Tax Rates Configuration</CardTitle>
              <CardDescription>
                Manage tax rates for different jurisdictions and tax types
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={taxRateColumns}
                data={taxRates}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="transactions" className="space-y-6">
          {/* Filters */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search transactions..."
                      className="pl-10"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                    />
                  </div>
                </div>
                <Select value={selectedType} onValueChange={setSelectedType}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Types" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Types</SelectItem>
                    <SelectItem value="invoice">Invoice</SelectItem>
                    <SelectItem value="expense">Expense</SelectItem>
                    <SelectItem value="payment">Payment</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={selectedJurisdiction} onValueChange={setSelectedJurisdiction}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Jurisdictions" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Jurisdictions</SelectItem>
                    <SelectItem value="New York, NY">New York, NY</SelectItem>
                    <SelectItem value="United Kingdom">United Kingdom</SelectItem>
                    <SelectItem value="Canada">Canada</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Tax Transactions</CardTitle>
              <CardDescription>
                {filteredTransactions.length} of {taxTransactions.length} transactions
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={transactionColumns}
                data={filteredTransactions}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="periods" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Tax Filing Periods</CardTitle>
              <CardDescription>
                Track tax obligations by filing period
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={periodColumns}
                data={taxPeriods}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="calculator" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Tax Calculator</CardTitle>
              <CardDescription>
                Calculate tax amounts for invoices and expenses
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="calcAmount">Amount (before tax)</Label>
                    <Input
                      id="calcAmount"
                      type="number"
                      step="0.01"
                      placeholder="1000.00"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="calcTaxRate">Tax Rate</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select tax rate" />
                      </SelectTrigger>
                      <SelectContent>
                        {taxRates.filter(r => r.status === "active").map((rate) => (
                          <SelectItem key={rate.id} value={rate.id}>
                            {rate.name} ({rate.rate}%)
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <Button className="w-full">
                    <Calculator className="h-4 w-4 mr-2" />
                    Calculate Tax
                  </Button>
                </div>
                <div className="space-y-4">
                  <div className="p-4 border rounded-lg">
                    <h3 className="font-medium mb-4">Calculation Results</h3>
                    <div className="space-y-2">
                      <div className="flex justify-between">
                        <span className="text-sm">Subtotal:</span>
                        <span className="financial-amount">$0.00</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm">Tax Amount:</span>
                        <span className="financial-amount">$0.00</span>
                      </div>
                      <div className="flex justify-between font-medium pt-2 border-t">
                        <span>Total:</span>
                        <span className="financial-amount">$0.00</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}