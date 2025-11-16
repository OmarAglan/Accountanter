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
import { Progress } from "./ui/progress";
import { toast } from "sonner@2.0.3";
import {
  Plus,
  Search,
  Download,
  CreditCard,
  DollarSign,
  TrendingUp,
  AlertCircle,
  CheckCircle,
  Clock,
  RefreshCw,
  Banknote,
  Building,
  Calendar,
  Filter,
  MoreHorizontal,
  Link,
  Receipt,
} from "lucide-react";

interface PaymentTrackingProps {
  onRecordPayment?: () => void;
}

interface Payment {
  id: string;
  invoiceId: string;
  clientName: string;
  amount: number;
  paymentDate: string;
  dueDate: string;
  paymentMethod: string;
  status: "completed" | "pending" | "failed" | "refunded";
  reference: string;
  fees?: number;
  currency: string;
  gateway?: string;
}

interface PaymentMethod {
  id: string;
  name: string;
  type: "bank_transfer" | "credit_card" | "paypal" | "stripe" | "cash" | "check";
  fees: number;
  processingTime: string;
  enabled: boolean;
}

const samplePayments: Payment[] = [
  {
    id: "PAY-001",
    invoiceId: "INV-2024-001",
    clientName: "Acme Corp",
    amount: 2500.00,
    paymentDate: "2024-01-15",
    dueDate: "2024-01-15",
    paymentMethod: "Bank Transfer",
    status: "completed",
    reference: "TXN-456789",
    currency: "USD",
    gateway: "Bank",
  },
  {
    id: "PAY-002",
    invoiceId: "INV-2024-002",
    clientName: "TechStart Inc",
    amount: 1750.00,
    paymentDate: "2024-01-12",
    dueDate: "2024-01-10",
    paymentMethod: "Credit Card",
    status: "completed",
    reference: "CH_3456789",
    fees: 52.50,
    currency: "USD",
    gateway: "Stripe",
  },
  {
    id: "PAY-003",
    invoiceId: "INV-2024-003",
    clientName: "Design Studio",
    amount: 850.00,
    paymentDate: "2024-01-08",
    dueDate: "2024-01-05",
    paymentMethod: "PayPal",
    status: "pending",
    reference: "PP-987654321",
    fees: 25.50,
    currency: "USD",
    gateway: "PayPal",
  },
  {
    id: "PAY-004",
    invoiceId: "INV-2024-004",
    clientName: "Global Solutions",
    amount: 3200.00,
    paymentDate: "2024-01-14",
    dueDate: "2024-01-20",
    paymentMethod: "Check",
    status: "completed",
    reference: "CHK-1001",
    currency: "USD",
  },
];

const paymentMethods: PaymentMethod[] = [
  {
    id: "bank_transfer",
    name: "Bank Transfer",
    type: "bank_transfer",
    fees: 0,
    processingTime: "1-3 business days",
    enabled: true,
  },
  {
    id: "stripe",
    name: "Credit Card (Stripe)",
    type: "stripe",
    fees: 2.9,
    processingTime: "Instant",
    enabled: true,
  },
  {
    id: "paypal",
    name: "PayPal",
    type: "paypal",
    fees: 3.5,
    processingTime: "Instant",
    enabled: true,
  },
  {
    id: "cash",
    name: "Cash",
    type: "cash",
    fees: 0,
    processingTime: "Instant",
    enabled: true,
  },
  {
    id: "check",
    name: "Check",
    type: "check",
    fees: 0,
    processingTime: "3-5 business days",
    enabled: true,
  },
];

export function PaymentTracking({ onRecordPayment }: PaymentTrackingProps) {
  const [payments, setPayments] = useState<Payment[]>(samplePayments);
  const [showRecordPayment, setShowRecordPayment] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [selectedMethod, setSelectedMethod] = useState("all");
  const [activeTab, setActiveTab] = useState("overview");

  const [newPayment, setNewPayment] = useState({
    invoiceId: "",
    amount: "",
    paymentMethod: "",
    paymentDate: new Date().toISOString().split('T')[0],
    reference: "",
    notes: "",
  });

  const filteredPayments = payments.filter((payment) => {
    const matchesSearch = payment.clientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         payment.invoiceId.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         payment.reference.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = selectedStatus === "all" || payment.status === selectedStatus;
    const matchesMethod = selectedMethod === "all" || payment.paymentMethod === selectedMethod;
    
    return matchesSearch && matchesStatus && matchesMethod;
  });

  const totalPayments = payments.reduce((sum, payment) => 
    payment.status === "completed" ? sum + payment.amount : sum, 0
  );
  const pendingPayments = payments.filter(p => p.status === "pending").reduce((sum, payment) => sum + payment.amount, 0);
  const totalFees = payments.reduce((sum, payment) => sum + (payment.fees || 0), 0);
  const completedCount = payments.filter(p => p.status === "completed").length;

  const handleRecordPayment = () => {
    if (!newPayment.invoiceId || !newPayment.amount || !newPayment.paymentMethod) {
      toast.error("Please fill in all required fields");
      return;
    }

    const payment: Payment = {
      id: `PAY-${String(payments.length + 1).padStart(3, '0')}`,
      invoiceId: newPayment.invoiceId,
      clientName: "Sample Client", // In real app, would lookup from invoice
      amount: parseFloat(newPayment.amount),
      paymentDate: newPayment.paymentDate,
      dueDate: newPayment.paymentDate, // Simplified
      paymentMethod: newPayment.paymentMethod,
      status: "completed",
      reference: newPayment.reference || `AUTO-${Date.now()}`,
      currency: "USD",
    };

    setPayments([payment, ...payments]);
    setNewPayment({
      invoiceId: "",
      amount: "",
      paymentMethod: "",
      paymentDate: new Date().toISOString().split('T')[0],
      reference: "",
      notes: "",
    });
    setShowRecordPayment(false);
    toast.success("Payment recorded successfully");
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed": return <CheckCircle className="h-4 w-4 text-success" />;
      case "pending": return <Clock className="h-4 w-4 text-warning" />;
      case "failed": return <AlertCircle className="h-4 w-4 text-destructive" />;
      case "refunded": return <RefreshCw className="h-4 w-4 text-muted-foreground" />;
      default: return <AlertCircle className="h-4 w-4" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed": return "success";
      case "pending": return "warning";
      case "failed": return "destructive";
      case "refunded": return "secondary";
      default: return "secondary";
    }
  };

  const getMethodIcon = (method: string) => {
    switch (method.toLowerCase()) {
      case "credit card":
      case "credit card (stripe)": return <CreditCard className="h-4 w-4" />;
      case "bank transfer": return <Building className="h-4 w-4" />;
      case "paypal": return <DollarSign className="h-4 w-4" />;
      case "cash": return <Banknote className="h-4 w-4" />;
      case "check": return <Receipt className="h-4 w-4" />;
      default: return <DollarSign className="h-4 w-4" />;
    }
  };

  const paymentColumns = [
    {
      accessorKey: "paymentDate",
      header: "Date",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("paymentDate"));
        return date.toLocaleDateString();
      },
    },
    {
      accessorKey: "invoiceId",
      header: "Invoice",
      cell: ({ row }: any) => {
        const payment = row.original;
        return (
          <div className="flex items-center gap-2">
            <Link className="h-4 w-4 text-muted-foreground" />
            <div>
              <div className="font-medium">{payment.invoiceId}</div>
              <div className="text-sm text-muted-foreground">{payment.clientName}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "amount",
      header: "Amount",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("amount"));
        const payment = row.original;
        return (
          <div>
            <div className="financial-amount font-medium">${amount.toFixed(2)}</div>
            {payment.fees && (
              <div className="text-sm text-muted-foreground">
                Fee: ${payment.fees.toFixed(2)}
              </div>
            )}
          </div>
        );
      },
    },
    {
      accessorKey: "paymentMethod",
      header: "Method",
      cell: ({ row }: any) => {
        const payment = row.original;
        return (
          <div className="flex items-center gap-2">
            {getMethodIcon(payment.paymentMethod)}
            <span>{payment.paymentMethod}</span>
          </div>
        );
      },
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }: any) => {
        const status = row.getValue("status");
        return (
          <div className="flex items-center gap-2">
            {getStatusIcon(status as string)}
            <Badge variant={getStatusColor(status as string) as any}>
              {status}
            </Badge>
          </div>
        );
      },
    },
    {
      accessorKey: "reference",
      header: "Reference",
      cell: ({ row }: any) => {
        const reference = row.getValue("reference");
        return <code className="text-sm bg-muted px-2 py-1 rounded">{reference}</code>;
      },
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Payment Tracking</h1>
          <p className="text-muted-foreground">
            Monitor and manage all payment transactions across your business.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
          <Dialog open={showRecordPayment} onOpenChange={setShowRecordPayment}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Record Payment
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Record New Payment</DialogTitle>
                <DialogDescription>
                  Record a payment received from a client.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="invoiceId">Invoice Number *</Label>
                    <Input
                      id="invoiceId"
                      placeholder="INV-2024-001"
                      value={newPayment.invoiceId}
                      onChange={(e) => setNewPayment(prev => ({ ...prev, invoiceId: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="amount">Amount *</Label>
                    <Input
                      id="amount"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      value={newPayment.amount}
                      onChange={(e) => setNewPayment(prev => ({ ...prev, amount: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="paymentMethod">Payment Method *</Label>
                    <Select value={newPayment.paymentMethod} onValueChange={(value) => setNewPayment(prev => ({ ...prev, paymentMethod: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select payment method" />
                      </SelectTrigger>
                      <SelectContent>
                        {paymentMethods.filter(m => m.enabled).map((method) => (
                          <SelectItem key={method.id} value={method.name}>
                            {method.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="paymentDate">Payment Date *</Label>
                    <Input
                      id="paymentDate"
                      type="date"
                      value={newPayment.paymentDate}
                      onChange={(e) => setNewPayment(prev => ({ ...prev, paymentDate: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="reference">Reference Number</Label>
                  <Input
                    id="reference"
                    placeholder="Transaction reference (optional)"
                    value={newPayment.reference}
                    onChange={(e) => setNewPayment(prev => ({ ...prev, reference: e.target.value }))}
                  />
                </div>

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowRecordPayment(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleRecordPayment}>
                    Record Payment
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="payments">All Payments</TabsTrigger>
          <TabsTrigger value="methods">Payment Methods</TabsTrigger>
          <TabsTrigger value="reconciliation">Reconciliation</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <CheckCircle className="h-4 w-4" />
                  Total Received
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount text-success">${totalPayments.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">{completedCount} payments</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Clock className="h-4 w-4" />
                  Pending
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount text-warning">${pendingPayments.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">{payments.filter(p => p.status === "pending").length} payments</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  Processing Fees
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount">${totalFees.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">Total fees paid</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <TrendingUp className="h-4 w-4" />
                  Collection Rate
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-success">94.2%</div>
                <p className="text-sm text-muted-foreground">This month</p>
              </CardContent>
            </Card>
          </div>

          {/* Recent Payments */}
          <Card>
            <CardHeader>
              <CardTitle>Recent Payments</CardTitle>
              <CardDescription>Latest payment transactions</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {payments.slice(0, 5).map((payment) => (
                  <div key={payment.id} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      {getMethodIcon(payment.paymentMethod)}
                      <div>
                        <div className="font-medium">{payment.invoiceId}</div>
                        <div className="text-sm text-muted-foreground">{payment.clientName}</div>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="text-right">
                        <div className="financial-amount font-medium">${payment.amount.toFixed(2)}</div>
                        <div className="text-sm text-muted-foreground">
                          {new Date(payment.paymentDate).toLocaleDateString()}
                        </div>
                      </div>
                      {getStatusIcon(payment.status)}
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payments" className="space-y-6">
          {/* Filters */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search payments..."
                      className="pl-10"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                    />
                  </div>
                </div>
                <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="completed">Completed</SelectItem>
                    <SelectItem value="pending">Pending</SelectItem>
                    <SelectItem value="failed">Failed</SelectItem>
                    <SelectItem value="refunded">Refunded</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={selectedMethod} onValueChange={setSelectedMethod}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Methods" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Methods</SelectItem>
                    {paymentMethods.map((method) => (
                      <SelectItem key={method.id} value={method.name}>
                        {method.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Payments Table */}
          <Card>
            <CardHeader>
              <CardTitle>Payment History</CardTitle>
              <CardDescription>
                {filteredPayments.length} of {payments.length} payments
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={paymentColumns}
                data={filteredPayments}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="methods" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Payment Methods Configuration</CardTitle>
              <CardDescription>
                Manage available payment methods and their settings
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {paymentMethods.map((method) => (
                  <div key={method.id} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center gap-3">
                      {getMethodIcon(method.name)}
                      <div>
                        <div className="font-medium">{method.name}</div>
                        <div className="text-sm text-muted-foreground">
                          {method.fees > 0 ? `${method.fees}% fee` : "No fees"} • {method.processingTime}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge variant={method.enabled ? "success" : "secondary"}>
                        {method.enabled ? "Enabled" : "Disabled"}
                      </Badge>
                      <Button variant="outline" size="sm">
                        Configure
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="reconciliation" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Payment Reconciliation</CardTitle>
              <CardDescription>
                Match payments with bank statements and resolve discrepancies
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-success">156</div>
                    <p className="text-sm text-muted-foreground">Matched Payments</p>
                  </div>
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-warning">3</div>
                    <p className="text-sm text-muted-foreground">Pending Review</p>
                  </div>
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-destructive">1</div>
                    <p className="text-sm text-muted-foreground">Discrepancies</p>
                  </div>
                </div>

                <div className="space-y-3">
                  <h3>Pending Reconciliation</h3>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between p-3 border rounded-lg">
                      <div>
                        <div className="font-medium">Bank Transaction: $2,500.00</div>
                        <div className="text-sm text-muted-foreground">Jan 15, 2024 • Reference: TXN-456789</div>
                      </div>
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline">Review</Button>
                        <Button size="sm">Match</Button>
                      </div>
                    </div>
                    <div className="flex items-center justify-between p-3 border rounded-lg">
                      <div>
                        <div className="font-medium">Bank Transaction: $1,750.00</div>
                        <div className="text-sm text-muted-foreground">Jan 12, 2024 • Reference: CH_3456789</div>
                      </div>
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline">Review</Button>
                        <Button size="sm">Match</Button>
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