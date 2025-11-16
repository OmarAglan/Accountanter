import { useState } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Trash2, Plus, ArrowLeft } from "lucide-react";

interface LineItem {
  id: string;
  description: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

interface InvoiceEditorProps {
  isEditing?: boolean;
  invoiceNumber?: string;
  onBack: () => void;
  onSave: (isDraft: boolean) => void;
}

export function InvoiceEditor({ 
  isEditing = false, 
  invoiceNumber, 
  onBack, 
  onSave 
}: InvoiceEditorProps) {
  const [selectedClient, setSelectedClient] = useState("");
  const [invoiceNum, setInvoiceNum] = useState(invoiceNumber || "INV-006");
  const [issueDate, setIssueDate] = useState(new Date().toISOString().split('T')[0]);
  const [dueDate, setDueDate] = useState("");
  const [lineItems, setLineItems] = useState<LineItem[]>([
    {
      id: "1",
      description: "",
      quantity: 1,
      unitPrice: 0,
      total: 0
    }
  ]);
  const [notes, setNotes] = useState("");

  const clients = [
    { id: "1", name: "Acme Corporation", email: "contact@acme.com" },
    { id: "2", name: "Tech Solutions Inc", email: "hello@techsolutions.com" },
    { id: "3", name: "Design Studio LLC", email: "projects@designstudio.com" },
    { id: "4", name: "Marketing Agency", email: "team@marketingagency.com" },
  ];

  const addLineItem = () => {
    const newItem: LineItem = {
      id: (lineItems.length + 1).toString(),
      description: "",
      quantity: 1,
      unitPrice: 0,
      total: 0
    };
    setLineItems([...lineItems, newItem]);
  };

  const removeLineItem = (id: string) => {
    setLineItems(lineItems.filter(item => item.id !== id));
  };

  const updateLineItem = (id: string, field: keyof LineItem, value: any) => {
    setLineItems(lineItems.map(item => {
      if (item.id === id) {
        const updated = { ...item, [field]: value };
        if (field === 'quantity' || field === 'unitPrice') {
          updated.total = updated.quantity * updated.unitPrice;
        }
        return updated;
      }
      return item;
    }));
  };

  const subtotal = lineItems.reduce((sum, item) => sum + item.total, 0);
  const taxRate = 0.1; // 10%
  const tax = subtotal * taxRate;
  const total = subtotal + tax;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={onBack} size="sm">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
          <div>
            <h1 className="tracking-tight">
              {isEditing ? `Edit Invoice ${invoiceNumber}` : "Create New Invoice"}
            </h1>
            <p className="text-muted-foreground">
              {isEditing ? "Update invoice details" : "Fill in the details to create a new invoice"}
            </p>
          </div>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" onClick={() => onSave(true)}>
            Save as Draft
          </Button>
          <Button className="bg-accent hover:bg-accent/90" onClick={() => onSave(false)}>
            Save and Send
          </Button>
        </div>
      </div>

      {/* Company and Client Details */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* From (Company Details) */}
        <Card className="card-shadow">
          <CardHeader>
            <CardTitle>From</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <p className="font-semibold text-foreground">Your Company Name</p>
              <p className="text-sm text-muted-foreground">123 Business Street</p>
              <p className="text-sm text-muted-foreground">Business City, BC 12345</p>
              <p className="text-sm text-muted-foreground">hello@yourcompany.com</p>
              <p className="text-sm text-muted-foreground">+1 (555) 123-4567</p>
            </div>
          </CardContent>
        </Card>

        {/* Bill To (Client Details) */}
        <Card className="card-shadow">
          <CardHeader>
            <CardTitle>Bill To</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="client">Select Client</Label>
              <Select value={selectedClient} onValueChange={setSelectedClient}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a client" />
                </SelectTrigger>
                <SelectContent>
                  {clients.map((client) => (
                    <SelectItem key={client.id} value={client.id}>
                      {client.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            {selectedClient && (
              <div className="text-sm text-muted-foreground">
                <p>{clients.find(c => c.id === selectedClient)?.name}</p>
                <p>{clients.find(c => c.id === selectedClient)?.email}</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Invoice Details */}
      <Card className="card-shadow">
        <CardHeader>
          <CardTitle>Invoice Details</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-3">
            <div className="space-y-2">
              <Label htmlFor="invoiceNumber">Invoice Number</Label>
              <Input
                id="invoiceNumber"
                value={invoiceNum}
                onChange={(e) => setInvoiceNum(e.target.value)}
                className="bg-input-background"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="issueDate">Issue Date</Label>
              <Input
                id="issueDate"
                type="date"
                value={issueDate}
                onChange={(e) => setIssueDate(e.target.value)}
                className="bg-input-background"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="dueDate">Due Date</Label>
              <Input
                id="dueDate"
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                className="bg-input-background"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Line Items */}
      <Card className="card-shadow">
        <CardHeader>
          <CardTitle>Line Items</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {/* Header */}
            <div className="grid grid-cols-12 gap-4 text-sm font-medium text-muted-foreground">
              <div className="col-span-5">Description</div>
              <div className="col-span-2 text-center">Quantity</div>
              <div className="col-span-2 text-right">Unit Price</div>
              <div className="col-span-2 text-right">Total</div>
              <div className="col-span-1"></div>
            </div>

            {/* Line Items */}
            {lineItems.map((item) => (
              <div key={item.id} className="grid grid-cols-12 gap-4 items-start">
                <div className="col-span-5">
                  <Textarea
                    placeholder="Item description"
                    value={item.description}
                    onChange={(e) => updateLineItem(item.id, 'description', e.target.value)}
                    className="min-h-[60px] bg-input-background"
                  />
                </div>
                <div className="col-span-2">
                  <Input
                    type="number"
                    min="1"
                    value={item.quantity}
                    onChange={(e) => updateLineItem(item.id, 'quantity', parseInt(e.target.value) || 0)}
                    className="text-center bg-input-background"
                  />
                </div>
                <div className="col-span-2">
                  <Input
                    type="number"
                    min="0"
                    step="0.01"
                    value={item.unitPrice}
                    onChange={(e) => updateLineItem(item.id, 'unitPrice', parseFloat(e.target.value) || 0)}
                    className="text-right bg-input-background"
                  />
                </div>
                <div className="col-span-2 text-right pt-3">
                  <span className="financial-amount font-medium">
                    ${item.total.toFixed(2)}
                  </span>
                </div>
                <div className="col-span-1 pt-3">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => removeLineItem(item.id)}
                    className="text-destructive hover:text-destructive"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))}

            <Button variant="outline" onClick={addLineItem} className="w-full">
              <Plus className="h-4 w-4 mr-2" />
              Add Line Item
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Summary and Notes */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Notes */}
        <Card className="card-shadow">
          <CardHeader>
            <CardTitle>Notes & Terms</CardTitle>
          </CardHeader>
          <CardContent>
            <Textarea
              placeholder="Payment terms, additional notes..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="min-h-[120px] bg-input-background"
            />
          </CardContent>
        </Card>

        {/* Summary */}
        <Card className="card-shadow">
          <CardHeader>
            <CardTitle>Summary</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Subtotal:</span>
                <span className="financial-amount">${subtotal.toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Tax (10%):</span>
                <span className="financial-amount">${tax.toFixed(2)}</span>
              </div>
              <div className="border-t border-border pt-4">
                <div className="flex justify-between">
                  <span className="font-semibold text-foreground">Total Amount Due:</span>
                  <span className="financial-amount font-semibold text-lg">
                    ${total.toFixed(2)}
                  </span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}