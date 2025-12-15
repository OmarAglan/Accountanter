import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Progress } from "./ui/progress";
import { DataTable } from "./DataTable";
import {
  ArrowLeft,
  Mail,
  Phone,
  MapPin,
  Building,
  Calendar,
  DollarSign,
  FileText,
  CreditCard,
  TrendingUp,
  Edit,
  Trash2,
  Send,
  MoreHorizontal,
  Clock,
  CheckCircle,
  AlertCircle,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";

interface ClientDetailProps {
  clientId: string;
  onBack: () => void;
  onEditClient?: () => void;
  onDeleteClient?: () => void;
  onEditInvoice?: (invoiceId: string) => void;
}

export function ClientDetail({ clientId, onBack, onEditClient, onDeleteClient, onEditInvoice }: ClientDetailProps) {
  // Mock client data - in real app, this would be fetched based on clientId
  const client = {
    id: clientId,
    name: "Acme Corporation",
    type: "Debtor",
    email: "contact@acme.com",
    phone: "+1 (555) 123-4567",
    address: "123 Business Ave, Suite 100, New York, NY 10001",
    taxId: "12-3456789",
    outstandingBalance: 2500,
    totalRevenue: 45000,
    averagePaymentDays: 28,
    creditLimit: 50000,
    since: "2023-01-15",
    status: "Active",
    notes: "Preferred client - Net 30 payment terms. Monthly retainer agreement.",
  };

  const invoices = [
    {
      id: "INV-001",
      invoiceNumber: "INV-2024-001",
      amount: 2500,
      status: "Pending",
      dueDate: "2025-01-15",
      issueDate: "2024-12-16",
      description: "Web Development Services - December 2024",
    },
    {
      id: "INV-002",
      invoiceNumber: "INV-2024-002",
      amount: 2500,
      status: "Paid",
      dueDate: "2024-12-15",
      issueDate: "2024-11-16",
      description: "Web Development Services - November 2024",
      paidDate: "2024-12-10",
    },
    {
      id: "INV-003",
      invoiceNumber: "INV-2024-003",
      amount: 2500,
      status: "Paid",
      dueDate: "2024-11-15",
      issueDate: "2024-10-16",
      description: "Web Development Services - October 2024",
      paidDate: "2024-11-12",
    },
  ];

  const payments = [
    {
      id: "PAY-001",
      date: "2024-12-10",
      amount: 2500,
      method: "Bank Transfer",
      invoiceNumber: "INV-2024-002",
      reference: "TXN-456789",
    },
    {
      id: "PAY-002",
      date: "2024-11-12",
      amount: 2500,
      method: "Bank Transfer",
      invoiceNumber: "INV-2024-003",
      reference: "TXN-456788",
    },
  ];

  const activity = [
    {
      id: 1,
      type: "invoice_sent",
      description: "Invoice INV-2024-001 sent",
      date: "2024-12-16",
      icon: FileText,
      color: "text-accent",
    },
    {
      id: 2,
      type: "payment",
      description: "Payment received for INV-2024-002",
      date: "2024-12-10",
      icon: CheckCircle,
      color: "text-success",
    },
    {
      id: 3,
      type: "invoice_sent",
      description: "Invoice INV-2024-002 sent",
      date: "2024-11-16",
      icon: FileText,
      color: "text-accent",
    },
    {
      id: 4,
      type: "payment",
      description: "Payment received for INV-2024-003",
      date: "2024-11-12",
      icon: CheckCircle,
      color: "text-success",
    },
  ];

  const invoiceColumns = [
    { key: "invoiceNumber", label: "Invoice #" },
    { key: "description", label: "Description" },
    { key: "amount", label: "Amount", type: "currency" as const, align: "right" as const },
    { key: "status", label: "Status", type: "status" as const },
    { key: "dueDate", label: "Due Date", type: "date" as const },
    { key: "actions", label: "Actions", type: "actions" as const, align: "center" as const },
  ];

  const paymentColumns = [
    { key: "date", label: "Date", type: "date" as const },
    { key: "invoiceNumber", label: "Invoice" },
    { key: "method", label: "Method" },
    { key: "reference", label: "Reference" },
    { key: "amount", label: "Amount", type: "currency" as const, align: "right" as const },
  ];

  const creditUsagePercent = (client.outstandingBalance / client.creditLimit) * 100;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="outline" size="sm" onClick={onBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
          <div>
            <div className="flex items-center gap-3">
              <h1>{client.name}</h1>
              <Badge variant={client.type === "Debtor" ? "default" : "secondary"}>
                {client.type}
              </Badge>
              <Badge variant="outline" className="text-success border-success">
                {client.status}
              </Badge>
            </div>
            <p className="text-muted-foreground">Client since {new Date(client.since).toLocaleDateString()}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={onEditClient}>
            <Edit className="h-4 w-4 mr-2" />
            Edit
          </Button>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem>
                <Send className="h-4 w-4 mr-2" />
                Send Email
              </DropdownMenuItem>
              <DropdownMenuItem className="text-destructive">
                <Trash2 className="h-4 w-4 mr-2" />
                Delete Client
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card className="card-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <DollarSign className="h-4 w-4 text-warning" />
              Outstanding Balance
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="financial-amount text-2xl font-semibold text-warning">
              ${client.outstandingBalance.toLocaleString()}
            </div>
          </CardContent>
        </Card>

        <Card className="card-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-success" />
              Total Revenue
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="financial-amount text-2xl font-semibold text-success">
              ${client.totalRevenue.toLocaleString()}
            </div>
          </CardContent>
        </Card>

        <Card className="card-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <Clock className="h-4 w-4 text-accent" />
              Avg Payment Days
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-semibold">
              {client.averagePaymentDays} days
            </div>
          </CardContent>
        </Card>

        <Card className="card-shadow">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm font-medium flex items-center gap-2">
              <CreditCard className="h-4 w-4 text-primary" />
              Credit Limit
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="financial-amount text-2xl font-semibold">
              ${client.creditLimit.toLocaleString()}
            </div>
            <Progress value={creditUsagePercent} className="mt-2" />
            <p className="text-xs text-muted-foreground mt-1">
              {creditUsagePercent.toFixed(1)}% utilized
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Contact Information */}
      <Card className="card-shadow">
        <CardHeader>
          <CardTitle>Contact Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2">
            <div className="flex items-start gap-3">
              <Mail className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Email</p>
                <p className="text-sm text-muted-foreground">{client.email}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Phone className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Phone</p>
                <p className="text-sm text-muted-foreground">{client.phone}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <MapPin className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Address</p>
                <p className="text-sm text-muted-foreground">{client.address}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Building className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Tax ID</p>
                <p className="text-sm text-muted-foreground">{client.taxId}</p>
              </div>
            </div>
          </div>
          {client.notes && (
            <div className="mt-4 pt-4 border-t border-border">
              <p className="text-sm font-medium mb-2">Notes</p>
              <p className="text-sm text-muted-foreground">{client.notes}</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Tabs */}
      <Tabs defaultValue="invoices" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="invoices">Invoices</TabsTrigger>
          <TabsTrigger value="payments">Payments</TabsTrigger>
          <TabsTrigger value="activity">Activity</TabsTrigger>
        </TabsList>

        <TabsContent value="invoices" className="mt-6">
          <Card className="card-shadow">
            <CardHeader>
              <CardTitle>Invoice History</CardTitle>
              <CardDescription>All invoices for this client</CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                data={invoices}
                columns={invoiceColumns}
                onRowClick={(invoice) => onEditInvoice?.(invoice.id)}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="payments" className="mt-6">
          <Card className="card-shadow">
            <CardHeader>
              <CardTitle>Payment History</CardTitle>
              <CardDescription>All payments received from this client</CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable data={payments} columns={paymentColumns} />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="activity" className="mt-6">
          <Card className="card-shadow">
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
              <CardDescription>Timeline of interactions with this client</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {activity.map((item) => (
                  <div key={item.id} className="flex items-start gap-4 pb-4 border-b border-border last:border-0 last:pb-0">
                    <div className={`p-2 rounded-lg bg-muted ${item.color}`}>
                      <item.icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{item.description}</p>
                      <p className="text-sm text-muted-foreground flex items-center gap-1 mt-1">
                        <Calendar className="h-3 w-3" />
                        {new Date(item.date).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
