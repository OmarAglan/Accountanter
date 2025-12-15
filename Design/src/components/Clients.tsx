import { useState } from "react";
import { DataTable } from "./DataTable";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Plus, Search, Filter, Users, CreditCard, Banknote, Trash2, Mail, Eye } from "lucide-react";
import { Badge } from "./ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "./ui/dialog";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import { Checkbox } from "./ui/checkbox";
import { toast } from "sonner@2.0.3";
import { ClientDetail } from "./ClientDetail";

export function Clients() {
  const [searchTerm, setSearchTerm] = useState("");
  const [filterType, setFilterType] = useState("all");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [selectedClients, setSelectedClients] = useState<string[]>([]);
  const [selectedClientId, setSelectedClientId] = useState<string | null>(null);

  const clientsData = [
    {
      id: "CLI-001",
      name: "Acme Corporation",
      type: "Debtor",
      outstandingBalance: 2500,
      email: "contact@acme.com",
      phone: "+1 (555) 123-4567",
    },
    {
      id: "CLI-002",
      name: "Tech Solutions Inc",
      type: "Debtor",
      outstandingBalance: 1800,
      email: "hello@techsolutions.com",
      phone: "+1 (555) 987-6543",
    },
    {
      id: "CLI-003",
      name: "Design Studio LLC",
      type: "Debtor",
      outstandingBalance: -500, // Credit balance
      email: "projects@designstudio.com",
      phone: "+1 (555) 456-7890",
    },
    {
      id: "CLI-004",
      name: "Marketing Agency",
      type: "Creditor",
      outstandingBalance: -1200, // We owe them
      email: "team@marketingagency.com",
      phone: "+1 (555) 321-0987",
    },
    {
      id: "CLI-005",
      name: "Global Systems",
      type: "Debtor",
      outstandingBalance: 4100,
      email: "info@globalsystems.com",
      phone: "+1 (555) 654-3210",
    },
  ];

  const clientColumns = [
    { 
      key: "name", 
      label: "Client Name", 
      sortable: true 
    },
    { 
      key: "type", 
      label: "Type", 
      type: "status" as const 
    },
    { 
      key: "outstandingBalance", 
      label: "Outstanding Balance", 
      type: "currency" as const, 
      align: "right" as const, 
      sortable: true 
    },
    { 
      key: "email", 
      label: "Email" 
    },
    { 
      key: "actions", 
      label: "Actions", 
      type: "actions" as const, 
      align: "center" as const 
    },
  ];

  const getFilteredClients = () => {
    let filtered = clientsData;

    // Filter by type
    if (filterType !== "all") {
      if (filterType === "debtors") {
        filtered = filtered.filter(client => client.type === "Debtor");
      } else if (filterType === "creditors") {
        filtered = filtered.filter(client => client.type === "Creditor");
      }
    }

    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(client =>
        client.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        client.email.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    return filtered;
  };

  const filteredClients = getFilteredClients();

  const totalClients = clientsData.length;
  const debtors = clientsData.filter(c => c.type === "Debtor").length;
  const creditors = clientsData.filter(c => c.type === "Creditor").length;
  const totalReceivables = clientsData
    .filter(c => c.outstandingBalance > 0)
    .reduce((sum, c) => sum + c.outstandingBalance, 0);
  const totalPayables = Math.abs(clientsData
    .filter(c => c.outstandingBalance < 0)
    .reduce((sum, c) => sum + c.outstandingBalance, 0));

  const handleSelectAll = () => {
    if (selectedClients.length === filteredClients.length) {
      setSelectedClients([]);
    } else {
      setSelectedClients(filteredClients.map(c => c.id));
    }
  };

  const handleSelectClient = (clientId: string) => {
    setSelectedClients(prev => 
      prev.includes(clientId) 
        ? prev.filter(id => id !== clientId)
        : [...prev, clientId]
    );
  };

  const handleBulkEmail = () => {
    toast.success(`Sending email to ${selectedClients.length} client(s)`);
    setSelectedClients([]);
  };

  const handleBulkDelete = () => {
    toast.success(`Deleted ${selectedClients.length} client(s)`);
    setSelectedClients([]);
  };

  const handleViewClient = (clientId: string) => {
    setSelectedClientId(clientId);
  };

  if (selectedClientId) {
    return (
      <ClientDetail 
        clientId={selectedClientId}
        onBack={() => setSelectedClientId(null)}
        onEditClient={() => toast.info("Edit client functionality")}
        onDeleteClient={() => {
          toast.success("Client deleted");
          setSelectedClientId(null);
        }}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="tracking-tight">Clients</h1>
          <p className="text-muted-foreground">
            Manage your client relationships and outstanding balances.
          </p>
        </div>
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button className="bg-accent hover:bg-accent/90">
              <Plus className="mr-2 h-4 w-4" />
              Add New Client
            </Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-[600px]">
            <DialogHeader>
              <DialogTitle>Add New Client</DialogTitle>
              <DialogDescription>
                Enter the client's information to add them to your database.
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="clientName">Client Name</Label>
                  <Input id="clientName" placeholder="Enter client name" className="bg-input-background" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" type="email" placeholder="client@example.com" className="bg-input-background" />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone</Label>
                  <Input id="phone" placeholder="+1 (555) 123-4567" className="bg-input-background" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="type">Type</Label>
                  <Select>
                    <SelectTrigger className="bg-input-background">
                      <SelectValue placeholder="Select type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="debtor">Debtor</SelectItem>
                      <SelectItem value="creditor">Creditor</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="address">Address</Label>
                <Textarea id="address" placeholder="Client address" className="bg-input-background" />
              </div>
              <div className="space-y-2">
                <Label htmlFor="notes">Notes</Label>
                <Textarea id="notes" placeholder="Additional notes about the client" className="bg-input-background" />
              </div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={() => setIsDialogOpen(false)} className="bg-accent hover:bg-accent/90">
                Add Client
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Summary Cards */}
      <div className="grid gap-4 md:grid-cols-4">
        <Card className="card-shadow border-t-4 border-t-primary">
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-primary/10 p-3 rounded-lg">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold">
                  {totalClients}
                </div>
                <p className="text-sm text-muted-foreground">Total Clients</p>
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card className="card-shadow border-t-4 border-t-success">
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-success/10 p-3 rounded-lg">
                <CreditCard className="h-6 w-6 text-success" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold text-success">
                  ${totalReceivables.toLocaleString()}
                </div>
                <p className="text-sm text-muted-foreground">Total Receivables</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="card-shadow border-t-4 border-t-warning">
          <CardContent className="pt-6">
            <div className="flex items-center space-x-4">
              <div className="bg-warning/10 p-3 rounded-lg">
                <Banknote className="h-6 w-6 text-warning" />
              </div>
              <div>
                <div className="financial-amount text-2xl font-semibold text-warning">
                  ${totalPayables.toLocaleString()}
                </div>
                <p className="text-sm text-muted-foreground">Total Payables</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="card-shadow border-t-4 border-t-accent">
          <CardContent className="pt-6">
            <div className="text-center">
              <div className="flex justify-center gap-4 mb-2">
                <div className="text-center">
                  <div className="financial-amount text-lg font-semibold text-accent">
                    {debtors}
                  </div>
                  <p className="text-xs text-muted-foreground">Debtors</p>
                </div>
                <div className="text-center">
                  <div className="financial-amount text-lg font-semibold text-accent">
                    {creditors}
                  </div>
                  <p className="text-xs text-muted-foreground">Creditors</p>
                </div>
              </div>
              <p className="text-sm text-muted-foreground">Client Breakdown</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search and Filters */}
      <Card className="card-shadow">
        <CardContent className="pt-6">
          <div className="flex items-center gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search clients by name or email..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 bg-input-background"
              />
            </div>
            <Select value={filterType} onValueChange={setFilterType}>
              <SelectTrigger className="w-48 bg-input-background">
                <SelectValue placeholder="Filter by type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Clients</SelectItem>
                <SelectItem value="debtors">Debtors</SelectItem>
                <SelectItem value="creditors">Creditors</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Bulk Actions Bar */}
      {selectedClients.length > 0 && (
        <Card className="card-shadow bg-accent/10 border-accent">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <p className="font-medium">
                {selectedClients.length} client{selectedClients.length !== 1 ? 's' : ''} selected
              </p>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={handleBulkEmail}>
                  <Mail className="h-4 w-4 mr-2" />
                  Send Email
                </Button>
                <Button variant="outline" size="sm" onClick={handleBulkDelete} className="text-destructive hover:text-destructive">
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete
                </Button>
                <Button variant="ghost" size="sm" onClick={() => setSelectedClients([])}>
                  Clear Selection
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Clients Table */}
      <Card className="card-shadow border-t-4 border-t-primary">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Client List</CardTitle>
              <p className="text-sm text-muted-foreground">
                {filteredClients.length} of {totalClients} clients
              </p>
            </div>
            <div className="flex items-center gap-2">
              <Checkbox 
                checked={selectedClients.length === filteredClients.length && filteredClients.length > 0}
                onCheckedChange={handleSelectAll}
              />
              <span className="text-sm text-muted-foreground">Select All</span>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            {filteredClients.map((client) => (
              <div 
                key={client.id}
                className="flex items-center gap-4 p-4 rounded-lg border border-border hover:bg-muted/50 transition-colors"
              >
                <Checkbox 
                  checked={selectedClients.includes(client.id)}
                  onCheckedChange={() => handleSelectClient(client.id)}
                />
                <div className="flex-1 grid grid-cols-4 gap-4 items-center">
                  <div>
                    <p className="font-medium">{client.name}</p>
                    <p className="text-sm text-muted-foreground">{client.email}</p>
                  </div>
                  <div>
                    <Badge variant={client.type === "Debtor" ? "default" : "secondary"}>
                      {client.type}
                    </Badge>
                  </div>
                  <div className="text-right">
                    <p className={`financial-amount font-semibold ${
                      client.outstandingBalance > 0 ? 'text-warning' :
                      client.outstandingBalance < 0 ? 'text-success' :
                      'text-muted-foreground'
                    }`}>
                      ${Math.abs(client.outstandingBalance).toLocaleString()}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {client.outstandingBalance > 0 ? 'Receivable' : 
                       client.outstandingBalance < 0 ? 'Payable' : 'Settled'}
                    </p>
                  </div>
                  <div className="flex gap-2 justify-end">
                    <Button 
                      variant="outline" 
                      size="sm"
                      onClick={() => handleViewClient(client.id)}
                    >
                      <Eye className="h-4 w-4 mr-2" />
                      View Details
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}