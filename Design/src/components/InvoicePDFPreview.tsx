import { Dialog, DialogContent, DialogHeader, DialogTitle } from "./ui/dialog";
import { Button } from "./ui/button";
import { Card } from "./ui/card";
import { Badge } from "./ui/badge";
import { Separator } from "./ui/separator";
import { Download, Printer, Send, X } from "lucide-react";
import { toast } from "sonner@2.0.3";

interface InvoiceData {
  invoiceNumber: string;
  issueDate: string;
  dueDate: string;
  clientName: string;
  clientEmail: string;
  clientAddress: string;
  status: string;
  items: Array<{
    description: string;
    quantity: number;
    rate: number;
    amount: number;
  }>;
  subtotal: number;
  tax: number;
  total: number;
  notes?: string;
  terms?: string;
}

interface InvoicePDFPreviewProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  invoice: InvoiceData;
  onSendEmail?: () => void;
}

export function InvoicePDFPreview({ open, onOpenChange, invoice, onSendEmail }: InvoicePDFPreviewProps) {
  const handleDownloadPDF = () => {
    toast.success("PDF downloaded successfully");
    // In a real implementation, use a library like jsPDF or react-pdf
    console.log("Downloading PDF for invoice:", invoice.invoiceNumber);
  };

  const handlePrint = () => {
    window.print();
    toast.success("Print dialog opened");
  };

  const handleSendEmail = () => {
    onSendEmail?.();
    toast.success(`Invoice sent to ${invoice.clientEmail}`);
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "paid":
        return "bg-success text-success-foreground";
      case "pending":
        return "bg-warning text-warning-foreground";
      case "overdue":
        return "bg-destructive text-destructive-foreground";
      case "draft":
        return "bg-muted text-muted-foreground";
      default:
        return "bg-primary text-primary-foreground";
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl max-h-[90vh] p-0">
        <DialogHeader className="p-6 pb-0">
          <div className="flex items-center justify-between">
            <DialogTitle>Invoice Preview</DialogTitle>
            <div className="flex items-center gap-2">
              <Button variant="outline" size="sm" onClick={handlePrint}>
                <Printer className="h-4 w-4 mr-2" />
                Print
              </Button>
              <Button variant="outline" size="sm" onClick={handleDownloadPDF}>
                <Download className="h-4 w-4 mr-2" />
                Download PDF
              </Button>
              <Button size="sm" onClick={handleSendEmail}>
                <Send className="h-4 w-4 mr-2" />
                Send Email
              </Button>
            </div>
          </div>
        </DialogHeader>

        {/* Invoice Preview */}
        <div className="overflow-y-auto px-6 pb-6">
          <Card className="p-8 bg-white" id="invoice-preview">
            {/* Company Header */}
            <div className="flex items-start justify-between mb-8">
              <div>
                <h2 className="text-3xl font-bold text-primary mb-2">Accountanter</h2>
                <p className="text-sm text-muted-foreground">123 Business Street</p>
                <p className="text-sm text-muted-foreground">New York, NY 10001</p>
                <p className="text-sm text-muted-foreground">contact@accountanter.com</p>
                <p className="text-sm text-muted-foreground">+1 (555) 123-4567</p>
              </div>
              <div className="text-right">
                <Badge className={`${getStatusColor(invoice.status)} mb-4`}>
                  {invoice.status.toUpperCase()}
                </Badge>
                <h3 className="text-2xl font-bold text-foreground">INVOICE</h3>
                <p className="text-sm text-muted-foreground mt-2">
                  <span className="font-medium">Invoice #:</span> {invoice.invoiceNumber}
                </p>
                <p className="text-sm text-muted-foreground">
                  <span className="font-medium">Issue Date:</span>{" "}
                  {new Date(invoice.issueDate).toLocaleDateString()}
                </p>
                <p className="text-sm text-muted-foreground">
                  <span className="font-medium">Due Date:</span>{" "}
                  {new Date(invoice.dueDate).toLocaleDateString()}
                </p>
              </div>
            </div>

            <Separator className="my-6" />

            {/* Bill To */}
            <div className="mb-8">
              <h4 className="font-semibold text-sm mb-2 text-muted-foreground">BILL TO:</h4>
              <p className="font-semibold text-foreground">{invoice.clientName}</p>
              <p className="text-sm text-muted-foreground">{invoice.clientEmail}</p>
              <p className="text-sm text-muted-foreground">{invoice.clientAddress}</p>
            </div>

            {/* Line Items */}
            <div className="mb-8">
              <table className="w-full">
                <thead>
                  <tr className="border-b-2 border-border">
                    <th className="text-left py-3 text-sm font-semibold text-muted-foreground">
                      DESCRIPTION
                    </th>
                    <th className="text-right py-3 text-sm font-semibold text-muted-foreground w-24">
                      QTY
                    </th>
                    <th className="text-right py-3 text-sm font-semibold text-muted-foreground w-32">
                      RATE
                    </th>
                    <th className="text-right py-3 text-sm font-semibold text-muted-foreground w-32">
                      AMOUNT
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {invoice.items.map((item, index) => (
                    <tr key={index} className="border-b border-border">
                      <td className="py-4 text-sm text-foreground">{item.description}</td>
                      <td className="py-4 text-sm text-right text-foreground">{item.quantity}</td>
                      <td className="py-4 text-sm text-right text-foreground financial-amount">
                        ${item.rate.toFixed(2)}
                      </td>
                      <td className="py-4 text-sm text-right text-foreground financial-amount">
                        ${item.amount.toFixed(2)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Totals */}
            <div className="flex justify-end mb-8">
              <div className="w-80">
                <div className="flex justify-between py-2">
                  <span className="text-sm text-muted-foreground">Subtotal:</span>
                  <span className="text-sm font-medium financial-amount">
                    ${invoice.subtotal.toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between py-2">
                  <span className="text-sm text-muted-foreground">Tax (10%):</span>
                  <span className="text-sm font-medium financial-amount">
                    ${invoice.tax.toFixed(2)}
                  </span>
                </div>
                <Separator className="my-2" />
                <div className="flex justify-between py-2">
                  <span className="font-semibold">Total:</span>
                  <span className="text-xl font-bold text-primary financial-amount">
                    ${invoice.total.toFixed(2)}
                  </span>
                </div>
              </div>
            </div>

            {/* Notes and Terms */}
            {(invoice.notes || invoice.terms) && (
              <>
                <Separator className="my-6" />
                <div className="grid gap-6 md:grid-cols-2">
                  {invoice.notes && (
                    <div>
                      <h4 className="font-semibold text-sm mb-2 text-muted-foreground">NOTES:</h4>
                      <p className="text-sm text-foreground">{invoice.notes}</p>
                    </div>
                  )}
                  {invoice.terms && (
                    <div>
                      <h4 className="font-semibold text-sm mb-2 text-muted-foreground">TERMS:</h4>
                      <p className="text-sm text-foreground">{invoice.terms}</p>
                    </div>
                  )}
                </div>
              </>
            )}

            {/* Footer */}
            <div className="mt-12 pt-6 border-t border-border text-center">
              <p className="text-xs text-muted-foreground">
                Thank you for your business!
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                For any questions, please contact us at contact@accountanter.com
              </p>
            </div>
          </Card>
        </div>
      </DialogContent>
    </Dialog>
  );
}
