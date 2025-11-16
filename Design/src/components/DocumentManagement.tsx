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
import { Textarea } from "./ui/textarea";
import { Progress } from "./ui/progress";
import { toast } from "sonner@2.0.3";
import {
  Plus,
  Search,
  Download,
  Upload,
  FileText,
  FileImage,
  File,
  Video,
  FileCheck,
  Folder,
  FolderPlus,
  Eye,
  Edit,
  Trash2,
  Share2,
  Archive,
  Tag,
  Calendar,
  User,
  Building,
  Receipt,
  Link,
  Shield,
  Clock,
  Filter,
} from "lucide-react";

interface DocumentManagementProps {
  onUploadDocument?: () => void;
}

interface Document {
  id: string;
  name: string;
  type: "invoice" | "receipt" | "contract" | "tax_document" | "statement" | "other";
  category: string;
  fileType: string;
  size: number;
  uploadDate: string;
  lastModified: string;
  uploadedBy: string;
  tags: string[];
  status: "active" | "archived" | "expired";
  relatedEntity?: string;
  relatedId?: string;
  url?: string;
  confidential: boolean;
  expiryDate?: string;
  description?: string;
}

interface Folder {
  id: string;
  name: string;
  description: string;
  parentId?: string;
  documentCount: number;
  createdDate: string;
  color: string;
}

const sampleDocuments: Document[] = [
  {
    id: "DOC-001",
    name: "Invoice_INV-2024-001.pdf",
    type: "invoice",
    category: "Invoices",
    fileType: "PDF",
    size: 245760, // 240 KB
    uploadDate: "2024-01-15T10:30:00Z",
    lastModified: "2024-01-15T10:30:00Z",
    uploadedBy: "John Doe",
    tags: ["invoice", "client", "2024"],
    status: "active",
    relatedEntity: "Client",
    relatedId: "CLI-001",
    url: "#",
    confidential: false,
    description: "Invoice for software development services",
  },
  {
    id: "DOC-002",
    name: "Receipt_Office_Supplies.jpg",
    type: "receipt",
    category: "Expenses",
    fileType: "JPG",
    size: 1048576, // 1 MB
    uploadDate: "2024-01-14T14:20:00Z",
    lastModified: "2024-01-14T14:20:00Z",
    uploadedBy: "Jane Smith",
    tags: ["receipt", "office", "supplies"],
    status: "active",
    relatedEntity: "Expense",
    relatedId: "EXP-001",
    url: "#",
    confidential: false,
    description: "Receipt for office supplies purchase",
  },
  {
    id: "DOC-003",
    name: "Service_Agreement_TechStart.pdf",
    type: "contract",
    category: "Contracts",
    fileType: "PDF",
    size: 512000, // 500 KB
    uploadDate: "2024-01-10T09:15:00Z",
    lastModified: "2024-01-10T09:15:00Z",
    uploadedBy: "John Doe",
    tags: ["contract", "service", "agreement"],
    status: "active",
    relatedEntity: "Client",
    relatedId: "CLI-002",
    url: "#",
    confidential: true,
    expiryDate: "2024-12-31",
    description: "Service agreement with TechStart Inc",
  },
  {
    id: "DOC-004",
    name: "Tax_Form_2023.pdf",
    type: "tax_document",
    category: "Tax Documents",
    fileType: "PDF",
    size: 789000, // 770 KB
    uploadDate: "2024-01-08T16:45:00Z",
    lastModified: "2024-01-08T16:45:00Z",
    uploadedBy: "Accountant",
    tags: ["tax", "2023", "form"],
    status: "active",
    url: "#",
    confidential: true,
    description: "Tax form filing for 2023",
  },
];

const sampleFolders: Folder[] = [
  {
    id: "FOL-001",
    name: "2024 Invoices",
    description: "All invoices for 2024",
    documentCount: 25,
    createdDate: "2024-01-01T00:00:00Z",
    color: "blue",
  },
  {
    id: "FOL-002",
    name: "Expense Receipts",
    description: "Receipts for business expenses",
    documentCount: 48,
    createdDate: "2024-01-01T00:00:00Z",
    color: "green",
  },
  {
    id: "FOL-003",
    name: "Client Contracts",
    description: "Contracts and agreements with clients",
    documentCount: 12,
    createdDate: "2024-01-01T00:00:00Z",
    color: "purple",
  },
  {
    id: "FOL-004",
    name: "Tax Documents",
    description: "Tax forms and related documents",
    documentCount: 8,
    createdDate: "2024-01-01T00:00:00Z",
    color: "red",
  },
];

export function DocumentManagement({ onUploadDocument }: DocumentManagementProps) {
  const [documents, setDocuments] = useState<Document[]>(sampleDocuments);
  const [folders, setFolders] = useState<Folder[]>(sampleFolders);
  const [showUpload, setShowUpload] = useState(false);
  const [showCreateFolder, setShowCreateFolder] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedType, setSelectedType] = useState("all");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [activeTab, setActiveTab] = useState("documents");
  const [viewMode, setViewMode] = useState<"grid" | "list">("list");

  const [newDocument, setNewDocument] = useState({
    name: "",
    type: "",
    category: "",
    description: "",
    tags: "",
    confidential: false,
    relatedEntity: "",
    relatedId: "",
  });

  const [newFolder, setNewFolder] = useState({
    name: "",
    description: "",
    color: "blue",
  });

  const filteredDocuments = documents.filter((document) => {
    const matchesSearch = document.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         document.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         document.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesType = selectedType === "all" || document.type === selectedType;
    const matchesCategory = selectedCategory === "all" || document.category === selectedCategory;
    const matchesStatus = selectedStatus === "all" || document.status === selectedStatus;
    
    return matchesSearch && matchesType && matchesCategory && matchesStatus;
  });

  const totalDocuments = documents.length;
  const totalSize = documents.reduce((sum, doc) => sum + doc.size, 0);
  const recentDocuments = documents.slice(0, 5);
  const confidentialCount = documents.filter(d => d.confidential).length;

  const handleUploadDocument = () => {
    if (!newDocument.name || !newDocument.type || !newDocument.category) {
      toast.error("Please fill in all required fields");
      return;
    }

    const document: Document = {
      id: `DOC-${String(documents.length + 1).padStart(3, '0')}`,
      name: newDocument.name,
      type: newDocument.type as any,
      category: newDocument.category,
      fileType: "PDF", // Simplified
      size: Math.floor(Math.random() * 1000000) + 100000, // Random size
      uploadDate: new Date().toISOString(),
      lastModified: new Date().toISOString(),
      uploadedBy: "Current User",
      tags: newDocument.tags ? newDocument.tags.split(',').map(tag => tag.trim()) : [],
      status: "active",
      relatedEntity: newDocument.relatedEntity || undefined,
      relatedId: newDocument.relatedId || undefined,
      url: "#",
      confidential: newDocument.confidential,
      description: newDocument.description,
    };

    setDocuments([document, ...documents]);
    setNewDocument({
      name: "",
      type: "",
      category: "",
      description: "",
      tags: "",
      confidential: false,
      relatedEntity: "",
      relatedId: "",
    });
    setShowUpload(false);
    toast.success("Document uploaded successfully");
  };

  const handleCreateFolder = () => {
    if (!newFolder.name) {
      toast.error("Please enter a folder name");
      return;
    }

    const folder: Folder = {
      id: `FOL-${String(folders.length + 1).padStart(3, '0')}`,
      name: newFolder.name,
      description: newFolder.description,
      documentCount: 0,
      createdDate: new Date().toISOString(),
      color: newFolder.color,
    };

    setFolders([folder, ...folders]);
    setNewFolder({
      name: "",
      description: "",
      color: "blue",
    });
    setShowCreateFolder(false);
    toast.success("Folder created successfully");
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const getFileIcon = (fileType: string) => {
    switch (fileType.toLowerCase()) {
      case "pdf": return <FileCheck className="h-4 w-4 text-red-500" />;
      case "jpg":
      case "jpeg":
      case "png":
      case "gif": return <FileImage className="h-4 w-4 text-blue-500" />;
      case "xls":
      case "xlsx":
      case "csv": return <FileText className="h-4 w-4 text-green-500" />;
      case "mp4":
      case "avi":
      case "mov": return <Video className="h-4 w-4 text-purple-500" />;
      case "doc":
      case "docx":
      case "txt": return <FileText className="h-4 w-4 text-blue-600" />;
      default: return <File className="h-4 w-4 text-gray-500" />;
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case "invoice": return "blue";
      case "receipt": return "green";
      case "contract": return "purple";
      case "tax_document": return "red";
      case "statement": return "yellow";
      default: return "gray";
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active": return "success";
      case "archived": return "secondary";
      case "expired": return "destructive";
      default: return "secondary";
    }
  };

  const documentColumns = [
    {
      accessorKey: "name",
      header: "Document",
      cell: ({ row }: any) => {
        const document = row.original;
        return (
          <div className="flex items-center gap-2">
            {getFileIcon(document.fileType)}
            <div>
              <div className="font-medium">{document.name}</div>
              <div className="text-sm text-muted-foreground">{document.description}</div>
            </div>
          </div>
        );
      },
    },
    {
      accessorKey: "type",
      header: "Type",
      cell: ({ row }: any) => {
        const type = row.getValue("type");
        return (
          <Badge variant={getTypeColor(type as string) as any}>
            {type.replace('_', ' ')}
          </Badge>
        );
      },
    },
    {
      accessorKey: "size",
      header: "Size",
      cell: ({ row }: any) => {
        const size = row.getValue("size");
        return formatFileSize(size as number);
      },
    },
    {
      accessorKey: "uploadDate",
      header: "Upload Date",
      cell: ({ row }: any) => {
        const date = new Date(row.getValue("uploadDate"));
        return date.toLocaleDateString();
      },
    },
    {
      accessorKey: "uploadedBy",
      header: "Uploaded By",
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }: any) => {
        const status = row.getValue("status");
        const document = row.original;
        return (
          <div className="flex items-center gap-2">
            {document.confidential && <Shield className="h-3 w-3 text-warning" />}
            <Badge variant={getStatusColor(status as string) as any}>
              {status}
            </Badge>
          </div>
        );
      },
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }: any) => {
        const document = row.original;
        return (
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm">
              <Eye className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Download className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Share2 className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm" className="text-destructive hover:text-destructive">
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
          <h1>Document Management</h1>
          <p className="text-muted-foreground">
            Organize and manage all your business documents in one secure location.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Dialog open={showCreateFolder} onOpenChange={setShowCreateFolder}>
            <DialogTrigger asChild>
              <Button variant="outline">
                <FolderPlus className="h-4 w-4 mr-2" />
                New Folder
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Create New Folder</DialogTitle>
                <DialogDescription>
                  Create a new folder to organize your documents.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="folderName">Folder Name *</Label>
                  <Input
                    id="folderName"
                    placeholder="Enter folder name"
                    value={newFolder.name}
                    onChange={(e) => setNewFolder(prev => ({ ...prev, name: e.target.value }))}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="folderDescription">Description</Label>
                  <Textarea
                    id="folderDescription"
                    placeholder="Describe the folder contents"
                    value={newFolder.description}
                    onChange={(e) => setNewFolder(prev => ({ ...prev, description: e.target.value }))}
                    rows={3}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="folderColor">Color</Label>
                  <Select value={newFolder.color} onValueChange={(value) => setNewFolder(prev => ({ ...prev, color: value }))}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="blue">Blue</SelectItem>
                      <SelectItem value="green">Green</SelectItem>
                      <SelectItem value="purple">Purple</SelectItem>
                      <SelectItem value="red">Red</SelectItem>
                      <SelectItem value="yellow">Yellow</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowCreateFolder(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleCreateFolder}>
                    Create Folder
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>

          <Dialog open={showUpload} onOpenChange={setShowUpload}>
            <DialogTrigger asChild>
              <Button>
                <Upload className="h-4 w-4 mr-2" />
                Upload Document
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Upload Document</DialogTitle>
                <DialogDescription>
                  Upload a new document to your document library.
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="documentName">Document Name *</Label>
                    <Input
                      id="documentName"
                      placeholder="Document name"
                      value={newDocument.name}
                      onChange={(e) => setNewDocument(prev => ({ ...prev, name: e.target.value }))}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="documentType">Document Type *</Label>
                    <Select value={newDocument.type} onValueChange={(value) => setNewDocument(prev => ({ ...prev, type: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="invoice">Invoice</SelectItem>
                        <SelectItem value="receipt">Receipt</SelectItem>
                        <SelectItem value="contract">Contract</SelectItem>
                        <SelectItem value="tax_document">Tax Document</SelectItem>
                        <SelectItem value="statement">Statement</SelectItem>
                        <SelectItem value="other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="category">Category *</Label>
                  <Input
                    id="category"
                    placeholder="Document category"
                    value={newDocument.category}
                    onChange={(e) => setNewDocument(prev => ({ ...prev, category: e.target.value }))}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    placeholder="Describe the document"
                    value={newDocument.description}
                    onChange={(e) => setNewDocument(prev => ({ ...prev, description: e.target.value }))}
                    rows={3}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="tags">Tags</Label>
                  <Input
                    id="tags"
                    placeholder="Comma-separated tags"
                    value={newDocument.tags}
                    onChange={(e) => setNewDocument(prev => ({ ...prev, tags: e.target.value }))}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="relatedEntity">Related Entity</Label>
                    <Select value={newDocument.relatedEntity} onValueChange={(value) => setNewDocument(prev => ({ ...prev, relatedEntity: value }))}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select entity type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Client">Client</SelectItem>
                        <SelectItem value="Invoice">Invoice</SelectItem>
                        <SelectItem value="Expense">Expense</SelectItem>
                        <SelectItem value="Project">Project</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="relatedId">Related ID</Label>
                    <Input
                      id="relatedId"
                      placeholder="Entity ID"
                      value={newDocument.relatedId}
                      onChange={(e) => setNewDocument(prev => ({ ...prev, relatedId: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <Label>Confidential Document</Label>
                    <p className="text-sm text-muted-foreground">
                      Mark as confidential for restricted access
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Shield className="h-4 w-4 text-warning" />
                    <input
                      type="checkbox"
                      checked={newDocument.confidential}
                      onChange={(e) => setNewDocument(prev => ({ ...prev, confidential: e.target.checked }))}
                    />
                  </div>
                </div>

                <div className="p-4 border-2 border-dashed border-muted rounded-lg text-center">
                  <Upload className="h-8 w-8 mx-auto mb-2 text-muted-foreground" />
                  <p className="text-sm text-muted-foreground">
                    Click to upload or drag and drop your file here
                  </p>
                  <p className="text-xs text-muted-foreground mt-1">
                    Supports PDF, Images, Documents up to 10MB
                  </p>
                </div>

                <div className="flex justify-end gap-3">
                  <Button variant="outline" onClick={() => setShowUpload(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleUploadDocument}>
                    Upload Document
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="documents">Documents</TabsTrigger>
          <TabsTrigger value="folders">Folders</TabsTrigger>
          <TabsTrigger value="recent">Recent</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        </TabsList>

        <TabsContent value="documents" className="space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <FileText className="h-4 w-4" />
                  Total Documents
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{totalDocuments}</div>
                <p className="text-sm text-muted-foreground">{folders.length} folders</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Archive className="h-4 w-4" />
                  Storage Used
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{formatFileSize(totalSize)}</div>
                <Progress value={65} className="h-2 mt-2" />
                <p className="text-sm text-muted-foreground mt-1">65% of 10GB</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Shield className="h-4 w-4" />
                  Confidential
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-warning">{confidentialCount}</div>
                <p className="text-sm text-muted-foreground">Secure documents</p>
              </CardContent>
            </Card>
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                  <Clock className="h-4 w-4" />
                  This Month
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-success">+{Math.floor(totalDocuments * 0.3)}</div>
                <p className="text-sm text-muted-foreground">New documents</p>
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
                      placeholder="Search documents..."
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
                    <SelectItem value="receipt">Receipt</SelectItem>
                    <SelectItem value="contract">Contract</SelectItem>
                    <SelectItem value="tax_document">Tax Document</SelectItem>
                    <SelectItem value="statement">Statement</SelectItem>
                    <SelectItem value="other">Other</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                  <SelectTrigger className="w-full sm:w-[180px]">
                    <SelectValue placeholder="All Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="active">Active</SelectItem>
                    <SelectItem value="archived">Archived</SelectItem>
                    <SelectItem value="expired">Expired</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Documents Table */}
          <Card>
            <CardHeader>
              <CardTitle>Documents</CardTitle>
              <CardDescription>
                {filteredDocuments.length} of {documents.length} documents
              </CardDescription>
            </CardHeader>
            <CardContent>
              <DataTable
                columns={documentColumns}
                data={filteredDocuments}
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="folders" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {folders.map((folder) => (
              <Card key={folder.id} className="cursor-pointer hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex items-center gap-3">
                      <Folder className={`h-8 w-8 text-${folder.color}-500`} />
                      <div>
                        <div className="font-medium">{folder.name}</div>
                        <div className="text-sm text-muted-foreground">
                          {folder.documentCount} documents
                        </div>
                      </div>
                    </div>
                    <Button variant="ghost" size="sm">
                      <Edit className="h-4 w-4" />
                    </Button>
                  </div>
                  <p className="text-sm text-muted-foreground mt-3">
                    {folder.description}
                  </p>
                  <div className="text-xs text-muted-foreground mt-2">
                    Created {new Date(folder.createdDate).toLocaleDateString()}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="recent" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Recently Uploaded</CardTitle>
              <CardDescription>
                Documents uploaded in the last 30 days
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {recentDocuments.map((document) => (
                  <div key={document.id} className="flex items-center justify-between p-3 border rounded-lg">
                    <div className="flex items-center gap-3">
                      {getFileIcon(document.fileType)}
                      <div>
                        <div className="font-medium">{document.name}</div>
                        <div className="text-sm text-muted-foreground">
                          {document.uploadedBy} • {formatFileSize(document.size)} • {new Date(document.uploadDate).toLocaleDateString()}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      {document.confidential && <Shield className="h-4 w-4 text-warning" />}
                      <Badge variant={getTypeColor(document.type) as any}>
                        {document.type.replace('_', ' ')}
                      </Badge>
                      <Button variant="ghost" size="sm">
                        <Eye className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="analytics" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Document Types</CardTitle>
                <CardDescription>Breakdown by document type</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {["invoice", "receipt", "contract", "tax_document"].map((type) => {
                    const count = documents.filter(d => d.type === type).length;
                    const percentage = totalDocuments > 0 ? (count / totalDocuments) * 100 : 0;
                    
                    return (
                      <div key={type} className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <Badge variant={getTypeColor(type) as any}>
                            {type.replace('_', ' ')}
                          </Badge>
                        </div>
                        <div className="text-right">
                          <div className="font-medium">{count}</div>
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
                <CardTitle>Storage Analytics</CardTitle>
                <CardDescription>Storage usage by document type</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Total Used</span>
                    <span className="font-medium">{formatFileSize(totalSize)}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Available</span>
                    <span className="font-medium">{formatFileSize(10737418240 - totalSize)}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Largest File</span>
                    <span className="font-medium">
                      {formatFileSize(Math.max(...documents.map(d => d.size)))}
                    </span>
                  </div>
                  <div className="flex justify-between items-center font-medium pt-2 border-t">
                    <span>Storage Limit</span>
                    <span>10 GB</span>
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