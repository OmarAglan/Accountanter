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
  RefreshCw,
  TrendingUp,
  TrendingDown,
  DollarSign,
  Globe,
  Calculator,
  AlertCircle,
  CheckCircle,
  Settings,
  Banknote,
  ArrowUpDown,
  Calendar,
  Building,
  Eye,
  Edit,
} from "lucide-react";

interface MultiCurrencyProps {
  onUpdateRates?: () => void;
}

interface Currency {
  code: string;
  name: string;
  symbol: string;
  rate: number; // Rate relative to base currency (USD)
  lastUpdated: string;
  status: "active" | "inactive";
  precision: number;
}

interface ExchangeRateHistory {
  date: string;
  fromCurrency: string;
  toCurrency: string;
  rate: number;
  source: string;
}

interface CurrencyTransaction {
  id: string;
  date: string;
  type: "invoice" | "payment" | "expense" | "conversion";
  description: string;
  originalCurrency: string;
  originalAmount: number;
  baseCurrency: string;
  baseAmount: number;
  exchangeRate: number;
  gainLoss?: number;
  reference: string;
  client?: string;
}

interface CurrencySettings {
  baseCurrency: string;
  autoUpdateRates: boolean;
  rateProvider: string;
  updateFrequency: "hourly" | "daily" | "weekly";
  rateVarianceAlert: number;
  showCurrencyOnInvoices: boolean;
}

const supportedCurrencies: Currency[] = [
  {
    code: "USD",
    name: "US Dollar",
    symbol: "$",
    rate: 1.0000,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
  {
    code: "EUR",
    name: "Euro",
    symbol: "€",
    rate: 0.9185,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
  {
    code: "GBP",
    name: "British Pound",
    symbol: "£",
    rate: 0.7865,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
  {
    code: "CAD",
    name: "Canadian Dollar",
    symbol: "C$",
    rate: 1.3425,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
  {
    code: "AUD",
    name: "Australian Dollar",
    symbol: "A$",
    rate: 1.4785,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
  {
    code: "JPY",
    name: "Japanese Yen",
    symbol: "¥",
    rate: 149.85,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 0,
  },
  {
    code: "CHF",
    name: "Swiss Franc",
    symbol: "Fr",
    rate: 0.8745,
    lastUpdated: "2024-01-15T10:30:00Z",
    status: "active",
    precision: 2,
  },
];

const sampleTransactions: CurrencyTransaction[] = [
  {
    id: "CT-001",
    date: "2024-01-15",
    type: "invoice",
    description: "Software Development - UK Client",
    originalCurrency: "GBP",
    originalAmount: 2000.00,
    baseCurrency: "USD",
    baseAmount: 2542.37,
    exchangeRate: 1.2712,
    reference: "INV-2024-001",
    client: "London Tech Ltd",
  },
  {
    id: "CT-002",
    date: "2024-01-12",
    type: "payment",
    description: "Payment from European Client",
    originalCurrency: "EUR",
    originalAmount: 1500.00,
    baseCurrency: "USD",
    baseAmount: 1633.61,
    exchangeRate: 1.0891,
    gainLoss: 15.25,
    reference: "PAY-2024-002",
    client: "Berlin Systems GmbH",
  },
  {
    id: "CT-003",
    date: "2024-01-10",
    type: "expense",
    description: "Marketing Services - Canadian Agency",
    originalCurrency: "CAD",
    originalAmount: 800.00,
    baseCurrency: "USD",
    baseAmount: 596.26,
    exchangeRate: 0.7453,
    reference: "EXP-2024-003",
  },
];

const rateHistory: ExchangeRateHistory[] = [
  {
    date: "2024-01-15",
    fromCurrency: "EUR",
    toCurrency: "USD",
    rate: 1.0891,
    source: "ECB",
  },
  {
    date: "2024-01-14",
    fromCurrency: "EUR",
    toCurrency: "USD",
    rate: 1.0876,
    source: "ECB",
  },
  {
    date: "2024-01-13",
    fromCurrency: "EUR",
    toCurrency: "USD",
    rate: 1.0895,
    source: "ECB",
  },
];

export function MultiCurrency({ onUpdateRates }: MultiCurrencyProps) {
  const [currencies, setCurrencies] = useState<Currency[]>(supportedCurrencies);
  const [transactions, setTransactions] = useState<CurrencyTransaction[]>(sampleTransactions);
  const [showConverter, setShowConverter] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCurrency, setSelectedCurrency] = useState("all");
  const [selectedType, setSelectedType] = useState("all");
  const [activeTab, setActiveTab] = useState("overview");

  const [converterFrom, setConverterFrom] = useState("");
  const [converterTo, setConverterTo] = useState("");
  const [converterAmount, setConverterAmount] = useState("");
  const [converterResult, setConverterResult] = useState("");

  const [settings, setSettings] = useState<CurrencySettings>({
    baseCurrency: "USD",
    autoUpdateRates: true,
    rateProvider: "ECB",
    updateFrequency: "daily",
    rateVarianceAlert: 5.0,
    showCurrencyOnInvoices: true,
  });

  const filteredTransactions = transactions.filter((transaction) => {
    const matchesSearch = transaction.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         transaction.reference.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (transaction.client && transaction.client.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesCurrency = selectedCurrency === "all" || 
                           transaction.originalCurrency === selectedCurrency ||
                           transaction.baseCurrency === selectedCurrency;
    const matchesType = selectedType === "all" || transaction.type === selectedType;
    
    return matchesSearch && matchesCurrency && matchesType;
  });

  const totalInBaseCurrency = transactions.reduce((sum, t) => sum + t.baseAmount, 0);
  const totalGainLoss = transactions.reduce((sum, t) => sum + (t.gainLoss || 0), 0);
  const currencyExposure = currencies.filter(c => c.status === "active" && c.code !== settings.baseCurrency).length;
  const lastRateUpdate = new Date(Math.max(...currencies.map(c => new Date(c.lastUpdated).getTime())));

  const handleConvert = () => {
    if (!converterFrom || !converterTo || !converterAmount) {
      toast.error("Please fill in all conversion fields");
      return;
    }

    const fromCurrency = currencies.find(c => c.code === converterFrom);
    const toCurrency = currencies.find(c => c.code === converterTo);

    if (!fromCurrency || !toCurrency) {
      toast.error("Invalid currency selection");
      return;
    }

    const amount = parseFloat(converterAmount);
    if (isNaN(amount)) {
      toast.error("Please enter a valid amount");
      return;
    }

    // Convert to base currency (USD) then to target currency
    const baseAmount = amount / fromCurrency.rate;
    const convertedAmount = baseAmount * toCurrency.rate;
    
    setConverterResult(convertedAmount.toFixed(toCurrency.precision));
    toast.success("Conversion calculated successfully");
  };

  const handleUpdateRates = () => {
    // Simulate rate update with small random changes
    setCurrencies(currencies.map(currency => {
      if (currency.code === "USD") return currency;
      
      const variance = (Math.random() - 0.5) * 0.02; // ±1% variance
      const newRate = currency.rate * (1 + variance);
      
      return {
        ...currency,
        rate: parseFloat(newRate.toFixed(6)),
        lastUpdated: new Date().toISOString(),
      };
    }));
    
    toast.success("Exchange rates updated successfully");
    onUpdateRates?.();
  };

  const formatCurrency = (amount: number, currencyCode: string) => {
    const currency = currencies.find(c => c.code === currencyCode);
    if (!currency) return `${amount.toFixed(2)} ${currencyCode}`;
    
    return `${currency.symbol}${amount.toFixed(currency.precision)}`;
  };

  const getRateChange = (currency: Currency) => {
    // Simulate rate change calculation
    const change = (Math.random() - 0.5) * 2; // ±1% change
    return change;
  };

  const currencyColumns = [
    {
      accessorKey: "code",
      header: "Currency",
      cell: ({ row }: any) => {
        const currency = row.original;
        return (
          <div className="flex items-center gap-2">
            <Globe className="h-4 w-4 text-muted-foreground" />
            <div>
              <div className="font-medium">{currency.code}</div>
              <div className="text-sm text-muted-foreground">{currency.name}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "symbol",
      header: "Symbol",
      cell: ({ row }: any) => {
        const symbol = row.getValue("symbol");
        return <span className="font-medium text-lg">{symbol}</span>;
      },
    },
    {
      accessorKey: "rate",
      header: "Exchange Rate",
      cell: ({ row }: any) => {
        const rate = parseFloat(row.getValue("rate"));
        const currency = row.original;
        const change = getRateChange(currency);
        return (
          <div>
            <div className="font-medium">{rate.toFixed(6)}</div>
            <div className={`text-sm flex items-center gap-1 ${change >= 0 ? 'text-success' : 'text-destructive'}`}>
              {change >= 0 ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
              {Math.abs(change).toFixed(2)}%
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "lastUpdated",
      header: "Last Updated",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("lastUpdated"));
        const now = new Date();
        const diffMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
        
        return (
          <div>
            <div className="text-sm">{date.toLocaleDateString()}</div>
            <div className="text-xs text-muted-foreground">
              {diffMinutes < 60 ? `${diffMinutes}m ago` : `${Math.floor(diffMinutes / 60)}h ago`}
            </div>
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
          <Badge variant={status === "active" ? "success" : "secondary"}>
            {status}
          </Badge>
        );
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const currency = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm">
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
          <div>
            <div className="font-medium">{transaction.reference}</div>
            <div className="text-sm text-muted-foreground capitalize">{transaction.type}</div>
          </div>
        );
      },
    },
    {
      accessorKey: "description",
      header: "Description",
      cell: ({ row }: any) => {
        const transaction = row.original;
        return (
          <div>
            <div className="font-medium">{transaction.description}</div>
            {transaction.client && (
              <div className="text-sm text-muted-foreground">{transaction.client}</div>
            )}
          </div>
        );
      },
    },
    {
      accessorKey: "originalAmount",
      header: "Original Amount",
      cell: ({ row }: any) => {
        const transaction = row.original;
        return (
          <div className="text-right">
            <div className="font-medium">
              {formatCurrency(transaction.originalAmount, transaction.originalCurrency)}
            </div>
            <div className="text-sm text-muted-foreground">
              Rate: {transaction.exchangeRate.toFixed(4)}
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "baseAmount",
      header: "Base Amount",
      cell: ({ row }: any) => {
        const transaction = row.original;
        return (
          <div className="text-right">
            <div className="font-medium financial-amount">
              {formatCurrency(transaction.baseAmount, transaction.baseCurrency)}
            </div>
            {transaction.gainLoss !== undefined && (
              <div className={`text-sm ${transaction.gainLoss >= 0 ? 'text-success' : 'text-destructive'}`}>
                {transaction.gainLoss >= 0 ? '+' : ''}{formatCurrency(transaction.gainLoss, transaction.baseCurrency)}
              </div>
            )}
          </div>
        );
      },
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Multi-Currency Management</h1>
          <p className="text-muted-foreground">
            Manage international transactions with real-time exchange rates and currency conversion.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="outline" onClick={handleUpdateRates}>
            <RefreshCw className="h-4 w-4 mr-2" />
            Update Rates
          </Button>
          <Dialog open={showConverter} onOpenChange={setShowConverter}>
            <DialogTrigger asChild>
              <Button>
                <Calculator className="h-4 w-4 mr-2" />
                Currency Converter
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Currency Converter</DialogTitle>
                <DialogDescription>
                  Convert between different currencies using current exchange rates.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="fromCurrency">From</Label>
                    <Select value={converterFrom} onValueChange={setConverterFrom}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select currency" />
                      </SelectTrigger>
                      <SelectContent>
                        {currencies.filter(c => c.status === "active").map((currency) => (
                          <SelectItem key={currency.code} value={currency.code}>
                            {currency.code} - {currency.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="toCurrency">To</Label>
                    <Select value={converterTo} onValueChange={setConverterTo}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select currency" />
                      </SelectTrigger>
                      <SelectContent>
                        {currencies.filter(c => c.status === "active").map((currency) => (
                          <SelectItem key={currency.code} value={currency.code}>
                            {currency.code} - {currency.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="amount">Amount</Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    placeholder="Enter amount"
                    value={converterAmount}
                    onChange={(e) => setConverterAmount(e.target.value)}
                  />
                </div>

                {converterResult && (
                  <div className="p-4 border rounded-lg bg-muted">
                    <div className="text-center">
                      <div className="text-2xl font-bold">
                        {converterTo && formatCurrency(parseFloat(converterResult), converterTo)}
                      </div>
                      <div className="text-sm text-muted-foreground mt-1">
                        Conversion Result
                      </div>
                    </div>
                  </div>
                )}

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowConverter(false)}>
                    Close
                  </Button>
                  <Button onClick={handleConvert}>
                    <ArrowUpDown className="h-4 w-4 mr-2" />
                    Convert
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
          <TabsTrigger value="currencies">Currencies</TabsTrigger>
          <TabsTrigger value="transactions">Transactions</TabsTrigger>
          <TabsTrigger value="rates">Exchange Rates</TabsTrigger>
          <TabsTrigger value="settings">Settings</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  Total Value (Base)
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold financial-amount">
                  {formatCurrency(totalInBaseCurrency, settings.baseCurrency)}
                </div>
                <p className="text-sm text-muted-foreground">All currencies</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <TrendingUp className="h-4 w-4" />
                  Currency Gain/Loss
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className={`text-2xl font-bold financial-amount ${totalGainLoss >= 0 ? 'text-success' : 'text-destructive'}`}>
                  {totalGainLoss >= 0 ? '+' : ''}{formatCurrency(totalGainLoss, settings.baseCurrency)}
                </div>
                <p className="text-sm text-muted-foreground">This period</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Globe className="h-4 w-4" />
                  Currency Exposure
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{currencyExposure}</div>
                <p className="text-sm text-muted-foreground">Active currencies</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <RefreshCw className="h-4 w-4" />
                  Last Rate Update
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {Math.floor((Date.now() - lastRateUpdate.getTime()) / (1000 * 60))}m
                </div>
                <p className="text-sm text-muted-foreground">Minutes ago</p>
              </CardContent>
            </Card>
          </div>

          {/* Currency Breakdown */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Currency Breakdown</CardTitle>
                <CardDescription>Transaction volume by currency</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {currencies.filter(c => c.status === "active").map((currency) => {
                    const currencyTransactions = transactions.filter(t => 
                      t.originalCurrency === currency.code || t.baseCurrency === currency.code
                    );
                    const totalVolume = currencyTransactions.reduce((sum, t) => 
                      t.originalCurrency === currency.code ? sum + t.originalAmount : sum + t.baseAmount, 0
                    );
                    const percentage = totalInBaseCurrency > 0 ? (totalVolume / totalInBaseCurrency) * 100 : 0;

                    return (
                      <div key={currency.code} className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-primary-foreground text-sm font-medium">
                            {currency.symbol}
                          </div>
                          <div>
                            <div className="font-medium">{currency.code}</div>
                            <div className="text-sm text-muted-foreground">{currency.name}</div>
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="font-medium">{formatCurrency(totalVolume, currency.code)}</div>
                          <div className="text-sm text-muted-foreground">{percentage.toFixed(1)}%</div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Rate Alerts</CardTitle>
                <CardDescription>Currency rate monitoring and alerts</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <AlertCircle className="h-4 w-4 text-warning" />
                      <div>
                        <p className="font-medium">EUR/USD Rate Alert</p>
                        <p className="text-sm text-muted-foreground">Rate exceeded 5% variance threshold</p>
                      </div>
                    </div>
                    <Badge variant="warning">Alert</Badge>
                  </div>
                  <div className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <CheckCircle className="h-4 w-4 text-success" />
                      <div>
                        <p className="font-medium">All Rates Updated</p>
                        <p className="text-sm text-muted-foreground">Successfully updated 15 minutes ago</p>
                      </div>
                    </div>
                    <Badge variant="success">OK</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="currencies" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Supported Currencies</CardTitle>
              <CardDescription>
                Manage currencies and their exchange rates
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={currencyColumns}
                data={currencies}
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
                <Select value={selectedCurrency} onValueChange={setSelectedCurrency}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Currencies" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Currencies</SelectItem>
                    {currencies.filter(c => c.status === "active").map((currency) => (
                      <SelectItem key={currency.code} value={currency.code}>
                        {currency.code}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Select value={selectedType} onValueChange={setSelectedType}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Types" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Types</SelectItem>
                    <SelectItem value="invoice">Invoice</SelectItem>
                    <SelectItem value="payment">Payment</SelectItem>
                    <SelectItem value="expense">Expense</SelectItem>
                    <SelectItem value="conversion">Conversion</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Currency Transactions</CardTitle>
              <CardDescription>
                {filteredTransactions.length} of {transactions.length} transactions
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

        <TabsContent value="rates" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Exchange Rate History</CardTitle>
              <CardDescription>
                Historical exchange rate data and trends
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {rateHistory.map((rate, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <ArrowUpDown className="h-4 w-4 text-muted-foreground" />
                      <div>
                        <div className="font-medium">{rate.fromCurrency}/{rate.toCurrency}</div>
                        <div className="text-sm text-muted-foreground">
                          {new Date(rate.date).toLocaleDateString()} • Source: {rate.source}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-medium">{rate.rate.toFixed(6)}</div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="settings" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Currency Settings</CardTitle>
              <CardDescription>
                Configure currency preferences and automation settings
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="baseCurrency">Base Currency</Label>
                  <Select value={settings.baseCurrency} onValueChange={(value) => setSettings(prev => ({ ...prev, baseCurrency: value }))}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {currencies.filter(c => c.status === "active").map((currency) => (
                        <SelectItem key={currency.code} value={currency.code}>
                          {currency.code} - {currency.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="rateProvider">Rate Provider</Label>
                  <Select value={settings.rateProvider} onValueChange={(value) => setSettings(prev => ({ ...prev, rateProvider: value }))}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="ECB">European Central Bank</SelectItem>
                      <SelectItem value="FED">Federal Reserve</SelectItem>
                      <SelectItem value="XE">XE.com</SelectItem>
                      <SelectItem value="OANDA">OANDA</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <Label>Auto-update Exchange Rates</Label>
                    <p className="text-sm text-muted-foreground">
                      Automatically fetch latest exchange rates
                    </p>
                  </div>
                  <Switch
                    checked={settings.autoUpdateRates}
                    onCheckedChange={(checked) => setSettings(prev => ({ ...prev, autoUpdateRates: checked }))}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <Label>Show Currency on Invoices</Label>
                    <p className="text-sm text-muted-foreground">
                      Display currency information on generated invoices
                    </p>
                  </div>
                  <Switch
                    checked={settings.showCurrencyOnInvoices}
                    onCheckedChange={(checked) => setSettings(prev => ({ ...prev, showCurrencyOnInvoices: checked }))}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="rateVarianceAlert">Rate Variance Alert (%)</Label>
                <Input
                  id="rateVarianceAlert"
                  type="number"
                  step="0.1"
                  value={settings.rateVarianceAlert}
                  onChange={(e) => setSettings(prev => ({ ...prev, rateVarianceAlert: parseFloat(e.target.value) }))}
                />
                <p className="text-sm text-muted-foreground">
                  Get alerted when exchange rates change by more than this percentage
                </p>
              </div>

              <div className="flex justify-end">
                <Button>
                  <Settings className="h-4 w-4 mr-2" />
                  Save Settings
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}