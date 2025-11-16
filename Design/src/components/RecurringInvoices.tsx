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
import { Textarea } from "./ui/textarea";
import { toast } from "sonner@2.0.3";
import {
  Plus,
  Search,
  Calendar,
  Repeat,
  Play,
  Pause,
  Settings,
  Eye,
  Edit,
  Trash2,
  RefreshCw,
  AlertCircle,
  CheckCircle,
  Clock,
  DollarSign,
  FileText,
  Users,
  TrendingUp,
} from "lucide-react";

interface RecurringInvoicesProps {
  onCreateRecurring?: () => void;
  onEditInvoice?: (invoiceId: string) => void;
}

interface RecurringInvoice {
  id: string;
  clientName: string;
  clientId: string;
  title: string;
  amount: number;
  frequency: "weekly" | "monthly" | "quarterly" | "yearly";
  startDate: string;
  nextDate: string;
  endDate?: string;
  status: "active" | "paused" | "completed" | "cancelled";
  totalInvoices: number;
  generatedInvoices: number;
  lastGenerated?: string;
  autoSend: boolean;
  template: string;
  description: string;
  currency: string;
}

interface GeneratedInvoice {
  id: string;
  recurringId: string;
  invoiceNumber: string;
  clientName: string;
  amount: number;
  generatedDate: string;
  dueDate: string;
  status: "draft" | "sent" | "paid" | "overdue";
  period: string;
}

const sampleRecurringInvoices: RecurringInvoice[] = [
  {
    id: "REC-001",
    clientName: "Acme Corp",
    clientId: "CLI-001",
    title: "Monthly Software Subscription",
    amount: 2500.00,
    frequency: "monthly",
    startDate: "2024-01-01",
    nextDate: "2024-02-01",
    status: "active",
    totalInvoices: 12,
    generatedInvoices: 1,
    lastGenerated: "2024-01-01",
    autoSend: true,
    template: "standard",
    description: "Monthly subscription for software services",
    currency: "USD",
  },
  {
    id: "REC-002",
    clientName: "TechStart Inc",
    clientId: "CLI-002",
    title: "Quarterly Consulting Retainer",
    amount: 7500.00,
    frequency: "quarterly",
    startDate: "2024-01-01",
    nextDate: "2024-04-01",
    status: "active",
    totalInvoices: 4,
    generatedInvoices: 1,
    lastGenerated: "2024-01-01",
    autoSend: true,
    template: "consulting",
    description: "Quarterly consulting retainer agreement",
    currency: "USD",
  },
  {
    id: "REC-003",
    clientName: "Design Studio",
    clientId: "CLI-003",
    title: "Weekly Content Creation",
    amount: 1200.00,
    frequency: "weekly",
    startDate: "2024-01-01",
    nextDate: "2024-01-08",
    endDate: "2024-06-30",
    status: "paused",
    totalInvoices: 26,
    generatedInvoices: 2,
    lastGenerated: "2024-01-08",
    autoSend: false,
    template: "creative",
    description: "Weekly content creation services",
    currency: "USD",
  },
];

const sampleGeneratedInvoices: GeneratedInvoice[] = [
  {
    id: "GEN-001",
    recurringId: "REC-001",
    invoiceNumber: "INV-2024-001",
    clientName: "Acme Corp",
    amount: 2500.00,
    generatedDate: "2024-01-01",
    dueDate: "2024-01-31",
    status: "paid",
    period: "January 2024",
  },
  {
    id: "GEN-002",
    recurringId: "REC-002",
    invoiceNumber: "INV-2024-002",
    clientName: "TechStart Inc",
    amount: 7500.00,
    generatedDate: "2024-01-01",
    dueDate: "2024-01-31",
    status: "sent",
    period: "Q1 2024",
  },
  {
    id: "GEN-003",
    recurringId: "REC-003",
    invoiceNumber: "INV-2024-003",
    clientName: "Design Studio",
    amount: 1200.00,
    generatedDate: "2024-01-01",
    dueDate: "2024-01-08",
    status: "paid",
    period: "Week 1 2024",
  },
];

export function RecurringInvoices({ onCreateRecurring, onEditInvoice }: RecurringInvoicesProps) {
  const [recurringInvoices, setRecurringInvoices] = useState<RecurringInvoice[]>(sampleRecurringInvoices);
  const [generatedInvoices, setGeneratedInvoices] = useState<GeneratedInvoice[]>(sampleGeneratedInvoices);
  const [showCreateRecurring, setShowCreateRecurring] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [selectedFrequency, setSelectedFrequency] = useState("all");
  const [activeTab, setActiveTab] = useState("recurring");

  const [newRecurring, setNewRecurring] = useState({
    clientId: "",
    title: "",
    amount: "",
    frequency: "",
    startDate: new Date().toISOString().split('T')[0],
    endDate: "",
    autoSend: true,
    description: "",
    template: "standard",
  });

  const filteredRecurring = recurringInvoices.filter((recurring) => {
    const matchesSearch = recurring.clientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         recurring.title.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = selectedStatus === "all" || recurring.status === selectedStatus;
    const matchesFrequency = selectedFrequency === "all" || recurring.frequency === selectedFrequency;
    
    return matchesSearch && matchesStatus && matchesFrequency;
  });

  const totalRecurring = recurringInvoices.length;
  const activeRecurring = recurringInvoices.filter(r => r.status === "active").length;
  const monthlyRevenue = recurringInvoices
    .filter(r => r.status === "active")
    .reduce((sum, r) => {
      const multiplier = r.frequency === "weekly" ? 4.33 : 
                        r.frequency === "monthly" ? 1 : 
                        r.frequency === "quarterly" ? 1/3 : 1/12;
      return sum + (r.amount * multiplier);
    }, 0);
  const nextDue = recurringInvoices
    .filter(r => r.status === "active")
    .sort((a, b) => new Date(a.nextDate).getTime() - new Date(b.nextDate).getTime())[0];

  const handleCreateRecurring = () => {
    if (!newRecurring.clientId || !newRecurring.title || !newRecurring.amount || !newRecurring.frequency) {
      toast.error("Please fill in all required fields");
      return;
    }

    const recurring: RecurringInvoice = {
      id: `REC-${String(recurringInvoices.length + 1).padStart(3, '0')}`,
      clientName: "Sample Client", // In real app, would lookup from clientId
      clientId: newRecurring.clientId,
      title: newRecurring.title,
      amount: parseFloat(newRecurring.amount),
      frequency: newRecurring.frequency as any,
      startDate: newRecurring.startDate,
      nextDate: newRecurring.startDate, // Simplified
      endDate: newRecurring.endDate || undefined,
      status: "active",
      totalInvoices: 0,
      generatedInvoices: 0,
      autoSend: newRecurring.autoSend,
      template: newRecurring.template,
      description: newRecurring.description,
      currency: "USD",
    };

    setRecurringInvoices([recurring, ...recurringInvoices]);
    setNewRecurring({
      clientId: "",
      title: "",
      amount: "",
      frequency: "",
      startDate: new Date().toISOString().split('T')[0],
      endDate: "",
      autoSend: true,
      description: "",
      template: "standard",
    });
    setShowCreateRecurring(false);
    toast.success("Recurring invoice created successfully");
  };

  const handleToggleStatus = (id: string) => {
    setRecurringInvoices(recurringInvoices.map(recurring => {
      if (recurring.id === id) {
        const newStatus = recurring.status === "active" ? "paused" : "active";
        toast.success(`Recurring invoice ${newStatus}`);
        return { ...recurring, status: newStatus };
      }
      return recurring;
    }));
  };

  const handleGenerateNow = (id: string) => {
    const recurring = recurringInvoices.find(r => r.id === id);
    if (recurring) {
      const newInvoice: GeneratedInvoice = {
        id: `GEN-${String(generatedInvoices.length + 1).padStart(3, '0')}`,
        recurringId: id,
        invoiceNumber: `INV-2024-${String(generatedInvoices.length + 1).padStart(3, '0')}`,
        clientName: recurring.clientName,
        amount: recurring.amount,
        generatedDate: new Date().toISOString().split('T')[0],
        dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        status: recurring.autoSend ? "sent" : "draft",
        period: "Manual Generation",
      };

      setGeneratedInvoices([newInvoice, ...generatedInvoices]);
      toast.success("Invoice generated successfully");
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "active": return <CheckCircle className="h-4 w-4 text-success" />;
      case "paused": return <Pause className="h-4 w-4 text-warning" />;
      case "completed": return <CheckCircle className="h-4 w-4 text-muted-foreground" />;
      case "cancelled": return <AlertCircle className="h-4 w-4 text-destructive" />;
      default: return <Clock className="h-4 w-4" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active": return "success";
      case "paused": return "warning";
      case "completed": return "secondary";
      case "cancelled": return "destructive";
      default: return "secondary";
    }
  };

  const getFrequencyIcon = (frequency: string) => {
    switch (frequency) {
      case "weekly": return <Calendar className="h-4 w-4" />;
      case "monthly": return <Calendar className="h-4 w-4" />;
      case "quarterly": return <Calendar className="h-4 w-4" />;
      case "yearly": return <Calendar className="h-4 w-4" />;
      default: return <Repeat className="h-4 w-4" />;
    }
  };

  const recurringColumns = [
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }: any) => {
        const recurring = row.original;
        return (
          <div className="flex items-center gap-2">
            {getFrequencyIcon(recurring.frequency)}
            <div>
              <div className="font-medium">{recurring.title}</div>
              <div className="text-sm text-muted-foreground">{recurring.clientName}</div>
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
        const recurring = row.original;
        return (
          <div>
            <div className="financial-amount font-medium">${amount.toFixed(2)}</div>
            <div className="text-sm text-muted-foreground capitalize">{recurring.frequency}</div>
          </div>
        );
      },
    },
    {
      accessorKey: "nextDate",
      header: "Next Due",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("nextDate"));
        const isOverdue = date < new Date();
        return (
          <div className={isOverdue ? "text-destructive" : ""}>
            {date.toLocaleDateString()}
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
      accessorKey: "generatedInvoices",
      header: "Generated",
      cell: ({ row }: any) => {
        const recurring = row.original;
        return (
          <div className="text-center">
            <div className="font-medium">{recurring.generatedInvoices}</div>
            {recurring.totalInvoices > 0 && (
              <div className="text-sm text-muted-foreground">
                of {recurring.totalInvoices}
              </div>
            )}
          </div>
        );
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const recurring = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" onClick={() => handleToggleStatus(recurring.id)}>
              {recurring.status === "active" ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
            </Button>
            <Button variant="ghost" size="sm" onClick={() => handleGenerateNow(recurring.id)}>
              <RefreshCw className="h-4 w-4" />
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

  const generatedColumns = [
    {
      accessorKey: "invoiceNumber",
      header: "Invoice",
      cell: ({ row }: any) => {
        const invoice = row.original;
        return (
          <div className="flex items-center gap-2">
            <FileText className="h-4 w-4 text-muted-foreground" />
            <div>
              <div className="font-medium">{invoice.invoiceNumber}</div>
              <div className="text-sm text-muted-foreground">{invoice.period}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "clientName",
      header: "Client",
    },
    {
      accessorKey: "amount",
      header: "Amount",
      cell: ({ row }: any) => {
        const amount = parseFloat(row.getValue("amount"));
        return <span className="financial-amount font-medium">${amount.toFixed(2)}</span>;
      },
    },
    {
      accessorKey: "generatedDate",
      header: "Generated",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("generatedDate"));
        return date.toLocaleDateString();
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
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }: any) => {
        const status = row.getValue("status");
        const getInvoiceStatusColor = (status: string) => {
          switch (status) {
            case "paid": return "success";
            case "sent": return "info";
            case "draft": return "secondary";
            case "overdue": return "destructive";
            default: return "secondary";
          }
        };
        return (
          <Badge variant={getInvoiceStatusColor(status as string) as any}>
            {status}
          </Badge>
        );
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const invoice = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" onClick={() => onEditInvoice?.(invoice.invoiceNumber)}>
              <Eye className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Edit className="h-4 w-4" />
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
          <h1>Recurring Invoices</h1>
          <p className="text-muted-foreground">
            Automate your billing with recurring invoice templates and schedules.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline">
            <Settings className="h-4 w-4 mr-2" />
            Templates
          </Button>
          <Dialog open={showCreateRecurring} onOpenChange={setShowCreateRecurring}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="h-4 w-4 mr-2" />
                Create Recurring
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Create Recurring Invoice</DialogTitle>
                <DialogDescription>
                  Set up automatic invoice generation for regular billing.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="clientId">Client *</Label>
                    <Select value={newRecurring.clientId} onValueChange={(value) => setNewRecurring(prev => ({ ...prev, clientId: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select client" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="CLI-001">Acme Corp</SelectItem>
                        <SelectItem value="CLI-002">TechStart Inc</SelectItem>
                        <SelectItem value="CLI-003">Design Studio</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="title">Title *</Label>
                    <Input
                      id="title"
                      placeholder="Monthly subscription"
                      value={newRecurring.title}
                      onChange={(e) => setNewRecurring(prev => ({ ...prev, title: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="amount">Amount *</Label>
                    <Input
                      id="amount"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      value={newRecurring.amount}
                      onChange={(e) => setNewRecurring(prev => ({ ...prev, amount: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="frequency">Frequency *</Label>
                    <Select value={newRecurring.frequency} onValueChange={(value) => setNewRecurring(prev => ({ ...prev, frequency: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select frequency" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="weekly">Weekly</SelectItem>
                        <SelectItem value="monthly">Monthly</SelectItem>
                        <SelectItem value="quarterly">Quarterly</SelectItem>
                        <SelectItem value="yearly">Yearly</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="startDate">Start Date *</Label>
                    <Input
                      id="startDate"
                      type="date"
                      value={newRecurring.startDate}
                      onChange={(e) => setNewRecurring(prev => ({ ...prev, startDate: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="endDate">End Date (Optional)</Label>
                    <Input
                      id="endDate"
                      type="date"
                      value={newRecurring.endDate}
                      onChange={(e) => setNewRecurring(prev => ({ ...prev, endDate: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    placeholder="Describe the recurring service..."
                    value={newRecurring.description}
                    onChange={(e) => setNewRecurring(prev => ({ ...prev, description: e.target.value }))}
                    rows={3}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <Label>Auto-send Invoices</Label>
                    <p className="text-sm text-muted-foreground">
                      Automatically send invoices when generated
                    </p>
                  </div>
                  <Switch
                    checked={newRecurring.autoSend}
                    onCheckedChange={(checked) => setNewRecurring(prev => ({ ...prev, autoSend: checked }))}
                  />
                </div>

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowCreateRecurring(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleCreateRecurring}>
                    Create Recurring Invoice
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="recurring">Recurring Invoices</TabsTrigger>
          <TabsTrigger value="generated">Generated Invoices</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        </TabsList>

        <TabsContent value="recurring" className="space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Repeat className="h-4 w-4" />
                  Total Recurring
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{totalRecurring}</div>
                <p className="text-sm text-muted-foreground">{activeRecurring} active</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  Monthly Revenue
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount text-success">${monthlyRevenue.toFixed(2)}</div>
                <p className="text-sm text-muted-foreground">Projected</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  Next Due
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {nextDue ? new Date(nextDue.nextDate).toLocaleDateString() : "None"}
                </div>
                <p className="text-sm text-muted-foreground">
                  {nextDue ? nextDue.clientName : "No active recurring"}
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <TrendingUp className="h-4 w-4" />
                  Success Rate
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-success">96.8%</div>
                <p className="text-sm text-muted-foreground">Payment success</p>
              </CardContent>
            </Card>
          </div>

          {/* Filters */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                    <Input
                      placeholder="Search recurring invoices..."
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
                    <SelectItem value="active">Active</SelectItem>
                    <SelectItem value="paused">Paused</SelectItem>
                    <SelectItem value="completed">Completed</SelectItem>
                    <SelectItem value="cancelled">Cancelled</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={selectedFrequency} onValueChange={setSelectedFrequency}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Frequencies" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Frequencies</SelectItem>
                    <SelectItem value="weekly">Weekly</SelectItem>
                    <SelectItem value="monthly">Monthly</SelectItem>
                    <SelectItem value="quarterly">Quarterly</SelectItem>
                    <SelectItem value="yearly">Yearly</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Recurring Invoices Table */}
          <Card>
            <CardHeader>
              <CardTitle>Recurring Invoice Templates</CardTitle>
              <CardDescription>
                {filteredRecurring.length} of {recurringInvoices.length} recurring invoices
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={recurringColumns}
                data={filteredRecurring}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="generated" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Generated Invoices</CardTitle>
              <CardDescription>
                Invoices automatically generated from recurring templates
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={generatedColumns}
                data={generatedInvoices}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="analytics" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Revenue Forecast</CardTitle>
                <CardDescription>Projected revenue from recurring invoices</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">This Month</span>
                    <span className="financial-amount font-medium">${monthlyRevenue.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Next Month</span>
                    <span className="financial-amount font-medium">${monthlyRevenue.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Next Quarter</span>
                    <span className="financial-amount font-medium">${(monthlyRevenue * 3).toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between items-center font-medium pt-2 border-t">
                    <span>Annual Projection</span>
                    <span className="financial-amount">${(monthlyRevenue * 12).toFixed(2)}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Performance Metrics</CardTitle>
                <CardDescription>Key recurring invoice statistics</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Average Invoice Value</span>
                    <span className="financial-amount font-medium">
                      ${(recurringInvoices.reduce((sum, r) => sum + r.amount, 0) / recurringInvoices.length).toFixed(2)}
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Client Retention Rate</span>
                    <span className="font-medium text-success">94.2%</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Average Contract Length</span>
                    <span className="font-medium">8.3 months</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Churn Rate</span>
                    <span className="font-medium text-destructive">5.8%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}