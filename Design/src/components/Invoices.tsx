import { useState, useEffect } from "react";
import { DataTable } from "./DataTable";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Plus, Search, Filter, Download, Eye, Send, Trash2, FileText } from "lucide-react";
import { Badge } from "./ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Checkbox } from "./ui/checkbox";
import { InvoicePDFPreview } from "./InvoicePDFPreview";
import { toast } from "sonner@2.0.3";

interface InvoicesProps {
  onCreateInvoice?: () => void;
  onEditInvoice?: (invoiceId: string) => void;
  filter?: string;
}

export function Invoices({ onCreateInvoice, onEditInvoice, filter }: InvoicesProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const [selectedInvoices, setSelectedInvoices] = useState<string[]>([]);
  const [previewInvoice, setPreviewInvoice] = useState<any>(null);
  const [showPDFPreview, setShowPDFPreview] = useState(false);

  // Apply filter from dashboard KPI clicks
  useEffect(() => {
    if (filter) {
      setActiveTab(filter);
    }
  }, [filter]);

  const invoicesData = [
    {
      id: "INV-001",
      client: "Acme Corporation",
      amount: 2500,
      status: "Paid",
      dueDate: "2025-01-15",
      issueDate: "2024-12-16",
      description: "Web Development Services",
    },
    {
      id: "INV-002",
      client: "Tech Solutions Inc",
      amount: 1800,
      status: "Pending",
      dueDate: "2025-02-10",
      issueDate: "2025-01-10",
      description: "UI/UX Design Project",
    },
    {
      id: "INV-003",
      client: "Design Studio LLC",
      amount: 3200,
      status: "Overdue",
      dueDate: "2024-12-28",
      issueDate: "2024-11-28",
      description: "Brand Identity Package",
    },
    {
      id: "INV-004",
      client: "Marketing Agency",
      amount: 950,
      status: "Draft",
      dueDate: "2025-02-08",
      issueDate: "2025-01-08",
      description: "SEO Consultation",
    },
    {
      id: "INV-005",
      client: "Global Systems",
      amount: 4100,
      status: "Pending",
      dueDate: "2025-02-20",
      issueDate: "2025-01-20",
      description: "System Integration",
    },
  ];

  const invoiceColumns = [
    { key: "id", label: "Invoice #" },
    { key: "client", label: "Client" },
    { key: "description", label: "Description" },
    { key: "amount", label: "Amount", type: "currency" as const, align: "right" as const },
    { key: "status", label: "Status", type: "status" as const },
    { key: "dueDate", label: "Due Date", type: "date" as const },
    { key: "actions", label: "Actions", type: "actions" as const, align: "center" as const },
  ];

  const getFilteredInvoices = () => {
    let filtered = invoicesData;

    if (activeTab !== "all") {
      filtered = filtered.filter(invoice => 
        invoice.status.toLowerCase() === activeTab
      );
    }

    if (searchTerm) {
      filtered = filtered.filter(invoice =>
        invoice.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
        invoice.client.toLowerCase().includes(searchTerm.toLowerCase()) ||
        invoice.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    return filtered;
  };

  const getStatusCounts = () => {
    return {
      all: invoicesData.length,
      paid: invoicesData.filter(i => i.status === "Paid").length,
      pending: invoicesData.filter(i => i.status === "Pending").length,
      overdue: invoicesData.filter(i => i.status === "Overdue").length,
      draft: invoicesData.filter(i => i.status === "Draft").length,
    };
  };

  const statusCounts = getStatusCounts();
  const filteredInvoices = getFilteredInvoices();

  const totalRevenue = invoicesData
    .filter(i => i.status === "Paid")
    .reduce((sum, invoice) => sum + invoice.amount, 0);

  const pendingRevenue = invoicesData
    .filter(i => i.status === "Pending")
    .reduce((sum, invoice) => sum + invoice.amount, 0);

  const overdueRevenue = invoicesData
    .filter(i => i.status === "Overdue")
    .reduce((sum, invoice) => sum + invoice.amount, 0);

  const handleSelectAll = () => {
    if (selectedInvoices.length === filteredInvoices.length) {
      setSelectedInvoices([]);
    } else {
      setSelectedInvoices(filteredInvoices.map(inv => inv.id));
    }
  };

  const handleSelectInvoice = (invoiceId: string) => {
    setSelectedInvoices(prev => 
      prev.includes(invoiceId) 
        ? prev.filter(id => id !== invoiceId)
        : [...prev, invoiceId]
    );
  };

  const handleBulkSend = () => {
    toast.success(`Sent ${selectedInvoices.length} invoice(s)`);
    setSelectedInvoices([]);
  };

  const handleBulkDelete = () => {
    toast.success(`Deleted ${selectedInvoices.length} invoice(s)`);
    setSelectedInvoices([]);
  };

  const handlePreviewInvoice = (invoice: any) => {
    setPreviewInvoice({
      invoiceNumber: invoice.id,
      issueDate: invoice.issueDate,
      dueDate: invoice.dueDate,
      clientName: invoice.client,
      clientEmail: "contact@example.com",
      clientAddress: "123 Client St, City, State 12345",
      status: invoice.status,
      items: [
        {
          description: invoice.description,
          quantity: 1,
          rate: invoice.amount,
          amount: invoice.amount,
        },
      ],
      subtotal: invoice.amount,
      tax: invoice.amount * 0.1,
      total: invoice.amount * 1.1,
      notes: "Thank you for your business!",
      terms: "Payment due within 30 days",
    });
    setShowPDFPreview(true);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="tracking-tight">Invoices</h1>
          <p className="text-muted-foreground">
            Create, manage, and track your invoices and payments.
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
          <Button onClick={onCreateInvoice}>
            <Plus className="mr-2 h-4 w-4" />
            New Invoice
          </Button>
        </div>
      </div>

      {/* Revenue Summary */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="financial-amount text-2xl font-semibold text-profit">
                ${totalRevenue.toLocaleString()}
              </div>
              <p className="text-sm text-muted-foreground">Paid Revenue</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="financial-amount text-2xl font-semibold text-pending">
                ${pendingRevenue.toLocaleString()}
              </div>
              <p className="text-sm text-muted-foreground">Pending Revenue</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="financial-amount text-2xl font-semibold text-overdue">
                ${overdueRevenue.toLocaleString()}
              </div>
              <p className="text-sm text-muted-foreground">Overdue Revenue</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="financial-amount text-2xl font-semibold">
                {invoicesData.length}
              </div>
              <p className="text-sm text-muted-foreground">Total Invoices</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search and Filters */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search invoices by ID, client, or description..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <Button variant="outline">
              <Filter className="mr-2 h-4 w-4" />
              Advanced Filter
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Bulk Actions Bar */}
      {selectedInvoices.length > 0 && (
        <Card className="card-shadow bg-accent/10 border-accent">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <p className="font-medium">
                {selectedInvoices.length} invoice{selectedInvoices.length !== 1 ? 's' : ''} selected
              </p>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={handleBulkSend}>
                  <Send className="h-4 w-4 mr-2" />
                  Send
                </Button>
                <Button variant="outline" size="sm" onClick={handleBulkDelete} className="text-destructive hover:text-destructive">
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete
                </Button>
                <Button variant="ghost" size="sm" onClick={() => setSelectedInvoices([])}>
                  Clear Selection
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Invoices Table with Tabs */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>Invoice Management</CardTitle>
            <div className="flex items-center gap-2">
              <Checkbox 
                checked={selectedInvoices.length === filteredInvoices.length && filteredInvoices.length > 0}
                onCheckedChange={handleSelectAll}
              />
              <span className="text-sm text-muted-foreground">Select All</span>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-5">
              <TabsTrigger value="all" className="relative">
                All
                <Badge variant="secondary" className="ml-2 text-xs">
                  {statusCounts.all}
                </Badge>
              </TabsTrigger>
              <TabsTrigger value="paid" className="relative">
                Paid
                <Badge variant="secondary" className="ml-2 text-xs">
                  {statusCounts.paid}
                </Badge>
              </TabsTrigger>
              <TabsTrigger value="pending" className="relative">
                Pending
                <Badge variant="secondary" className="ml-2 text-xs">
                  {statusCounts.pending}
                </Badge>
              </TabsTrigger>
              <TabsTrigger value="overdue" className="relative">
                Overdue
                <Badge variant="secondary" className="ml-2 text-xs">
                  {statusCounts.overdue}
                </Badge>
              </TabsTrigger>
              <TabsTrigger value="draft" className="relative">
                Draft
                <Badge variant="secondary" className="ml-2 text-xs">
                  {statusCounts.draft}
                </Badge>
              </TabsTrigger>
            </TabsList>
            <TabsContent value={activeTab} className="mt-6">
              <div className="space-y-2">
                {filteredInvoices.map((invoice) => (
                  <div 
                    key={invoice.id}
                    className="flex items-center gap-4 p-4 rounded-lg border border-border hover:bg-muted/50 transition-colors"
                  >
                    <Checkbox 
                      checked={selectedInvoices.includes(invoice.id)}
                      onCheckedChange={() => handleSelectInvoice(invoice.id)}
                    />
                    <div className="flex-1 grid grid-cols-5 gap-4 items-center">
                      <div>
                        <p className="font-medium">{invoice.id}</p>
                        <p className="text-sm text-muted-foreground">{invoice.client}</p>
                      </div>
                      <div>
                        <p className="text-sm">{invoice.description}</p>
                      </div>
                      <div className="text-right">
                        <p className="financial-amount font-semibold">
                          ${invoice.amount.toLocaleString()}
                        </p>
                      </div>
                      <div>
                        <Badge variant={
                          invoice.status === "Paid" ? "default" :
                          invoice.status === "Pending" ? "secondary" :
                          invoice.status === "Overdue" ? "destructive" :
                          "outline"
                        }>
                          {invoice.status}
                        </Badge>
                        <p className="text-xs text-muted-foreground mt-1">
                          Due: {new Date(invoice.dueDate).toLocaleDateString()}
                        </p>
                      </div>
                      <div className="flex gap-2 justify-end">
                        <Button 
                          variant="outline" 
                          size="sm"
                          onClick={() => handlePreviewInvoice(invoice)}
                        >
                          <Eye className="h-4 w-4 mr-2" />
                          Preview
                        </Button>
                        <Button 
                          variant="outline" 
                          size="sm"
                          onClick={() => onEditInvoice?.(invoice.id)}
                        >
                          <FileText className="h-4 w-4 mr-2" />
                          Edit
                        </Button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* PDF Preview Dialog */}
      {previewInvoice && (
        <InvoicePDFPreview 
          open={showPDFPreview}
          onOpenChange={setShowPDFPreview}
          invoice={previewInvoice}
          onSendEmail={() => toast.success(`Invoice sent to ${previewInvoice.clientEmail}`)}
        />
      )}
    </div>
  );
}