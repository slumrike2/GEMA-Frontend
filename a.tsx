'use client';

import type React from 'react';

import { useState, useMemo, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
	Dialog,
	DialogContent,
	DialogHeader,
	DialogTitle,
	DialogTrigger
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import {
	Select,
	SelectContent,
	SelectItem,
	SelectTrigger,
	SelectValue
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Separator } from '@/components/ui/separator';
import {
	Command,
	CommandEmpty,
	CommandGroup,
	CommandInput,
	CommandItem,
	CommandList
} from '@/components/ui/command';
import {
	Popover,
	PopoverContent,
	PopoverTrigger
} from '@/components/ui/popover';
import {
	ChevronDown,
	ChevronRight,
	Plus,
	Search,
	MapPin,
	Wrench,
	Building,
	Package,
	Truck,
	Check,
	ChevronsUpDown,
	Settings,
	Edit
} from 'lucide-react';
import { cn } from '@/lib/utils';

// Tipos de datos actualizados
interface Marca {
	id: string;
	nombre: string;
	descripcion?: string;
}

interface TipoUbicacion {
	id: string;
	nombre: string;
	plantillaNombre: string; // ej: "Salón {numero}"
	plantillaCodigo: string; // ej: "S-{numero}"
	descripcion?: string;
	variables: string[]; // ej: ["numero", "letra"]
}

interface UbicacionTecnica {
	id: string;
	codigo: string;
	nombre: string;
	tipoId: string;
	parentId?: string;
	childIds: string[];
	estado?: 'activa' | 'por_hacer_revision' | 'en_mantenimiento';
	// Variables específicas del tipo
	variables?: Record<string, string>;
}

interface Equipo {
	id: string;
	codigo: string;
	nombre: string;
	serial: string;
	marcaId: string;
	descripcion: string;
	ubicacionFisicaId?: string;
	ubicacionesOperativas: string[];
	estado:
		| 'en_inventario'
		| 'instalado'
		| 'en_mantenimiento'
		| 'por_hacer_mantenimiento'
		| 'por_mudar';
	ubicacionDestinoId?: string;
	fechaMudanza?: string;
	observaciones?: string;
}

// Datos iniciales de tipos de ubicación
const initialTipos: Record<string, TipoUbicacion> = {
	'tipo-sede': {
		id: 'tipo-sede',
		nombre: 'Sede',
		plantillaNombre: 'Sede {nombre}',
		plantillaCodigo: 'SEDE-{codigo}',
		variables: ['nombre', 'codigo'],
		descripcion: 'Campus o sede principal'
	},
	'tipo-edificio': {
		id: 'tipo-edificio',
		nombre: 'Edificio',
		plantillaNombre: 'Edificio {letra} - {descripcion}',
		plantillaCodigo: 'EDIF-{letra}',
		variables: ['letra', 'descripcion'],
		descripcion: 'Edificio dentro de una sede'
	},
	'tipo-piso': {
		id: 'tipo-piso',
		nombre: 'Piso',
		plantillaNombre: 'Piso {numero}',
		plantillaCodigo: 'P{numero}',
		variables: ['numero'],
		descripcion: 'Nivel dentro de un edificio'
	},
	'tipo-salon': {
		id: 'tipo-salon',
		nombre: 'Salón',
		plantillaNombre: 'Salón {numero}',
		plantillaCodigo: 'S-{numero}',
		variables: ['numero'],
		descripcion: 'Aula o salón de clases'
	},
	'tipo-laboratorio': {
		id: 'tipo-laboratorio',
		nombre: 'Laboratorio',
		plantillaNombre: 'Laboratorio de {especialidad}',
		plantillaCodigo: 'LAB-{codigo}',
		variables: ['especialidad', 'codigo'],
		descripcion: 'Laboratorio especializado'
	},
	'tipo-oficina': {
		id: 'tipo-oficina',
		nombre: 'Oficina',
		plantillaNombre: 'Oficina {numero}',
		plantillaCodigo: 'OF-{numero}',
		variables: ['numero'],
		descripcion: 'Oficina administrativa'
	}
};

const initialMarcas: Record<string, Marca> = {
	'marca-1': {
		id: 'marca-1',
		nombre: 'Carrier',
		descripcion: 'Sistemas de climatización'
	},
	'marca-2': {
		id: 'marca-2',
		nombre: 'LG',
		descripcion: 'Electrodomésticos y equipos electrónicos'
	},
	'marca-3': {
		id: 'marca-3',
		nombre: 'Dell',
		descripcion: 'Equipos de computación'
	},
	'marca-4': {
		id: 'marca-4',
		nombre: 'HP',
		descripcion: 'Impresoras y equipos de oficina'
	}
};

const initialUbicaciones: Record<string, UbicacionTecnica> = {
	ucab: {
		id: 'ucab',
		codigo: 'SEDE-GY',
		nombre: 'Sede Guayana',
		tipoId: 'tipo-sede',
		childIds: ['edif-a', 'edif-b'],
		estado: 'activa',
		variables: { nombre: 'Guayana', codigo: 'GY' }
	},
	'edif-a': {
		id: 'edif-a',
		codigo: 'EDIF-A',
		nombre: 'Edificio A - Administración',
		tipoId: 'tipo-edificio',
		parentId: 'ucab',
		childIds: ['edif-a-p1', 'edif-a-p2'],
		estado: 'activa',
		variables: { letra: 'A', descripcion: 'Administración' }
	},
	'edif-b': {
		id: 'edif-b',
		codigo: 'EDIF-B',
		nombre: 'Edificio B - Aulas',
		tipoId: 'tipo-edificio',
		parentId: 'ucab',
		childIds: ['edif-b-p1'],
		estado: 'activa',
		variables: { letra: 'B', descripcion: 'Aulas' }
	},
	'edif-a-p1': {
		id: 'edif-a-p1',
		codigo: 'P1',
		nombre: 'Piso 1',
		tipoId: 'tipo-piso',
		parentId: 'edif-a',
		childIds: ['salon-101', 'oficina-102'],
		estado: 'activa',
		variables: { numero: '1' }
	},
	'edif-a-p2': {
		id: 'edif-a-p2',
		codigo: 'P2',
		nombre: 'Piso 2',
		tipoId: 'tipo-piso',
		parentId: 'edif-a',
		childIds: ['salon-201'],
		estado: 'por_hacer_revision',
		variables: { numero: '2' }
	},
	'edif-b-p1': {
		id: 'edif-b-p1',
		codigo: 'P1',
		nombre: 'Piso 1',
		tipoId: 'tipo-piso',
		parentId: 'edif-b',
		childIds: ['lab-101'],
		estado: 'activa',
		variables: { numero: '1' }
	},
	'salon-101': {
		id: 'salon-101',
		codigo: 'S-101',
		nombre: 'Salón 101',
		tipoId: 'tipo-salon',
		parentId: 'edif-a-p1',
		childIds: [],
		estado: 'activa',
		variables: { numero: '101' }
	},
	'oficina-102': {
		id: 'oficina-102',
		codigo: 'OF-102',
		nombre: 'Oficina 102',
		tipoId: 'tipo-oficina',
		parentId: 'edif-a-p1',
		childIds: [],
		estado: 'activa',
		variables: { numero: '102' }
	},
	'salon-201': {
		id: 'salon-201',
		codigo: 'S-201',
		nombre: 'Salón 201',
		tipoId: 'tipo-salon',
		parentId: 'edif-a-p2',
		childIds: [],
		estado: 'en_mantenimiento',
		variables: { numero: '201' }
	},
	'lab-101': {
		id: 'lab-101',
		codigo: 'LAB-101',
		nombre: 'Laboratorio de Computación',
		tipoId: 'tipo-laboratorio',
		parentId: 'edif-b-p1',
		childIds: [],
		estado: 'activa',
		variables: { especialidad: 'Computación', codigo: '101' }
	}
};

const initialEquipos: Record<string, Equipo> = {
	'eq-001': {
		id: 'eq-001',
		codigo: 'AC-001',
		nombre: 'Aire Acondicionado Central',
		serial: 'CAR-2024-001',
		marcaId: 'marca-1',
		descripcion: 'Sistema de climatización central de 24000 BTU',
		ubicacionFisicaId: 'edif-a-p1',
		ubicacionesOperativas: ['salon-101', 'oficina-102'],
		estado: 'instalado',
		observaciones: 'Instalado en techo, opera en múltiples espacios'
	},
	'eq-002': {
		id: 'eq-002',
		codigo: 'PC-001',
		nombre: 'Computadora de Escritorio',
		serial: 'DELL-2024-002',
		marcaId: 'marca-3',
		descripcion: 'PC Dell OptiPlex para uso administrativo',
		ubicacionFisicaId: 'oficina-102',
		ubicacionesOperativas: ['oficina-102'],
		estado: 'por_mudar',
		ubicacionDestinoId: 'salon-201',
		fechaMudanza: '2024-01-15',
		observaciones: 'Mudanza programada para renovación de oficina'
	},
	'eq-003': {
		id: 'eq-003',
		codigo: 'IMP-001',
		nombre: 'Impresora Multifuncional',
		serial: 'HP-2024-003',
		marcaId: 'marca-4',
		descripcion: 'Impresora HP LaserJet multifuncional',
		estado: 'en_inventario',
		ubicacionesOperativas: [],
		observaciones: 'En almacén, pendiente de asignación'
	}
};

const estadoEquipoColors = {
	en_inventario: 'bg-gray-100 text-gray-800 border-gray-300',
	instalado: 'bg-green-100 text-green-800 border-green-300',
	en_mantenimiento: 'bg-red-100 text-red-800 border-red-300',
	por_hacer_mantenimiento: 'bg-yellow-100 text-yellow-800 border-yellow-300',
	por_mudar: 'bg-blue-100 text-blue-800 border-blue-300'
};

const estadoUbicacionColors = {
	activa: 'bg-green-100 text-green-800 border-green-300',
	por_hacer_revision: 'bg-yellow-100 text-yellow-800 border-yellow-300',
	en_mantenimiento: 'bg-red-100 text-red-800 border-red-300'
};

const tipoIcons = {
	'tipo-sede': Building,
	'tipo-edificio': Building,
	'tipo-piso': Package,
	'tipo-salon': MapPin,
	'tipo-laboratorio': Wrench,
	'tipo-oficina': MapPin
};

const NONE_SELECTED_VALUE = '__NONE__';

export default function SistemaUbicacionesUCAB() {
	const [ubicaciones, setUbicaciones] =
		useState<Record<string, UbicacionTecnica>>(initialUbicaciones);
	const [equipos, setEquipos] =
		useState<Record<string, Equipo>>(initialEquipos);
	const [marcas, setMarcas] = useState<Record<string, Marca>>(initialMarcas);
	const [tipos, setTipos] =
		useState<Record<string, TipoUbicacion>>(initialTipos);
	const [searchTerm, setSearchTerm] = useState('');
	const [expandedNodes, setExpandedNodes] = useState<Set<string>>(
		new Set(['ucab', 'edif-a'])
	);
	const [selectedItem, setSelectedItem] = useState<string | null>(null);
	const [selectedType, setSelectedType] = useState<'ubicacion' | 'equipo'>(
		'ubicacion'
	);
	const [activeTab, setActiveTab] = useState('ubicaciones');
	const [hoveredNodeId, setHoveredNodeId] = useState<string | null>(null);

	// Función para procesar plantillas
	const procesarPlantilla = (
		plantilla: string,
		variables: Record<string, string>
	): string => {
		let resultado = plantilla;
		Object.entries(variables).forEach(([key, value]) => {
			resultado = resultado.replace(new RegExp(`\\{${key}\\}`, 'g'), value);
		});
		return resultado;
	};

	// Función para obtener la ruta completa de códigos
	const getFullPath = (id: string): string => {
		const item = ubicaciones[id];
		if (!item) return '';

		const path = [item.codigo];
		let currentId = item.parentId;

		while (currentId) {
			const parent = ubicaciones[currentId];
			if (parent) {
				path.unshift(parent.codigo);
				currentId = parent.parentId;
			} else {
				break;
			}
		}

		return path.join(' → ');
	};

	const getMarcaNombre = (marcaId: string): string => {
		return marcas[marcaId]?.nombre || 'Sin marca';
	};

	const getUbicacionNombre = (ubicacionId: string): string => {
		return ubicaciones[ubicacionId]?.nombre || 'Ubicación no encontrada';
	};

	const getTipoNombre = (tipoId: string): string => {
		return tipos[tipoId]?.nombre || 'Tipo desconocido';
	};

	// Filtrar datos según búsqueda
	const filterUbicaciones = (searchTerm: string) => {
		if (!searchTerm) return ubicaciones;

		const filtered: Record<string, UbicacionTecnica> = {};

		Object.values(ubicaciones).forEach((item) => {
			const fullPath = getFullPath(item.id);
			const tipoNombre = getTipoNombre(item.tipoId);
			const matchesSearch =
				item.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
				item.codigo.toLowerCase().includes(searchTerm.toLowerCase()) ||
				fullPath.toLowerCase().includes(searchTerm.toLowerCase()) ||
				tipoNombre.toLowerCase().includes(searchTerm.toLowerCase());

			if (matchesSearch) {
				filtered[item.id] = item;
				// Incluir padres para mantener la estructura
				let parentId = item.parentId;
				while (parentId && !filtered[parentId]) {
					filtered[parentId] = ubicaciones[parentId];
					parentId = ubicaciones[parentId].parentId;
				}
			}
		});

		return filtered;
	};

	const filterEquipos = (searchTerm: string) => {
		if (!searchTerm) return equipos;

		return Object.fromEntries(
			Object.entries(equipos).filter(([_, equipo]) => {
				const marcaNombre = getMarcaNombre(equipo.marcaId);
				return (
					equipo.nombre.toLowerCase().includes(searchTerm.toLowerCase()) ||
					equipo.codigo.toLowerCase().includes(searchTerm.toLowerCase()) ||
					equipo.serial.toLowerCase().includes(searchTerm.toLowerCase()) ||
					marcaNombre.toLowerCase().includes(searchTerm.toLowerCase())
				);
			})
		);
	};

	const toggleExpanded = (id: string) => {
		const newExpanded = new Set(expandedNodes);
		if (newExpanded.has(id)) {
			newExpanded.delete(id);
		} else {
			newExpanded.add(id);
		}
		setExpandedNodes(newExpanded);
	};

	const renderTreeNode = (
		id: string,
		level = 0,
		filteredData: Record<string, UbicacionTecnica>
	) => {
		const item = filteredData[id];
		if (!item) return null;

		const tipo = tipos[item.tipoId];
		const Icon = tipoIcons[item.tipoId] || MapPin;
		const hasChildren = item.childIds.length > 0;
		const isExpanded = expandedNodes.has(id);
		const isSelected = selectedItem === id && selectedType === 'ubicacion';
		const isHovered = hoveredNodeId === id;

		return (
			<div key={id} className="select-none">
				<div
					className={`flex items-center gap-3 p-3 rounded-lg cursor-pointer hover:bg-green-50 border transition-colors relative ${
						isSelected
							? 'bg-green-100 border-green-300 shadow-sm'
							: 'border-transparent'
					}`}
					style={{ paddingLeft: `${level * 24 + 12}px` }}
					onClick={() => {
						setSelectedItem(id);
						setSelectedType('ubicacion');
					}}
					onMouseEnter={() => setHoveredNodeId(id)}
					onMouseLeave={() => setHoveredNodeId(null)}
				>
					{hasChildren ? (
						<Button
							variant="ghost"
							size="sm"
							className="h-7 w-7 p-0 hover:bg-green-200"
							onClick={(e) => {
								e.stopPropagation();
								toggleExpanded(id);
							}}
						>
							{isExpanded ? (
								<ChevronDown className="h-4 w-4" />
							) : (
								<ChevronRight className="h-4 w-4" />
							)}
						</Button>
					) : (
						<div className="w-7" />
					)}

					<Icon className="h-5 w-5 text-green-700" />

					<div className="flex-1 min-w-0">
						<div className="flex items-center gap-2 mb-1">
							<span className="font-medium text-gray-900">{item.nombre}</span>
							<Badge
								variant="outline"
								className="text-xs border-green-300 text-green-700"
							>
								{item.codigo}
							</Badge>
							<Badge
								variant="outline"
								className="text-xs border-gray-300 text-gray-600"
							>
								{tipo?.nombre}
							</Badge>
						</div>
						<div className="flex items-center gap-2">
							<span className="text-xs text-gray-600">{getFullPath(id)}</span>
							{item.estado && (
								<Badge
									className={`text-xs ${estadoUbicacionColors[item.estado]}`}
								>
									{item.estado.replace(/_/g, ' ')}
								</Badge>
							)}
						</div>
					</div>

					{/* Botón de insertar ubicación (estilo Excel) */}
					{isHovered && (
						<QuickInsertLocationDialog
							parentId={item.parentId}
							insertAfter={id}
							ubicaciones={ubicaciones}
							setUbicaciones={setUbicaciones}
							tipos={tipos}
							getFullPath={getFullPath}
							procesarPlantilla={procesarPlantilla}
						/>
					)}
				</div>

				{hasChildren && isExpanded && (
					<div>
						{item.childIds.map((childId) =>
							renderTreeNode(childId, level + 1, filteredData)
						)}
					</div>
				)}
			</div>
		);
	};

	const renderEquipoItem = (equipo: Equipo) => {
		const isSelected = selectedItem === equipo.id && selectedType === 'equipo';

		return (
			<div
				key={equipo.id}
				className={`p-4 rounded-lg cursor-pointer hover:bg-green-50 border transition-colors ${
					isSelected
						? 'bg-green-100 border-green-300 shadow-sm'
						: 'border-gray-200'
				}`}
				onClick={() => {
					setSelectedItem(equipo.id);
					setSelectedType('equipo');
				}}
			>
				<div className="flex items-start justify-between">
					<div className="flex items-center gap-3">
						<Wrench className="h-5 w-5 text-green-700" />
						<div>
							<div className="flex items-center gap-2 mb-1">
								<span className="font-medium text-gray-900">
									{equipo.nombre}
								</span>
								<Badge
									variant="outline"
									className="text-xs border-green-300 text-green-700"
								>
									{equipo.codigo}
								</Badge>
							</div>
							<div className="text-sm text-gray-600">
								{getMarcaNombre(equipo.marcaId)} • {equipo.serial}
							</div>
							{equipo.ubicacionFisicaId && (
								<div className="text-xs text-gray-500 mt-1">
									📍 {getUbicacionNombre(equipo.ubicacionFisicaId)}
								</div>
							)}
						</div>
					</div>
					<div className="flex flex-col items-end gap-1">
						<Badge className={`text-xs ${estadoEquipoColors[equipo.estado]}`}>
							{equipo.estado.replace(/_/g, ' ')}
						</Badge>
						{equipo.estado === 'por_mudar' && equipo.ubicacionDestinoId && (
							<div className="flex items-center gap-1 text-xs text-blue-600">
								<Truck className="h-3 w-3" />
								<span>→ {getUbicacionNombre(equipo.ubicacionDestinoId)}</span>
							</div>
						)}
					</div>
				</div>
			</div>
		);
	};

	const filteredUbicaciones = filterUbicaciones(searchTerm);
	const filteredEquipos = filterEquipos(searchTerm);
	const selectedItemData = selectedItem
		? selectedType === 'ubicacion'
			? ubicaciones[selectedItem]
			: equipos[selectedItem]
		: null;

	return (
		<div className="min-h-screen bg-gray-50">
			{/* Header */}
			<div className="bg-green-800 text-white p-4 shadow-lg">
				<div className="max-w-7xl mx-auto">
					<h1 className="text-2xl font-bold">
						Sistema de Gestión de Ubicaciones Técnicas
					</h1>
					<p className="text-green-100 mt-1">
						Universidad Católica Andrés Bello
					</p>
				</div>
			</div>

			<div className="max-w-full mx-auto p-6 md:px-8">
				<div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
					{/* Panel izquierdo - Navegación */}
					<div className="lg:col-span-1">
						<Card className="h-fit">
							<CardHeader className="pb-3">
								<div className="flex items-center justify-between">
									<CardTitle className="text-lg text-green-800">
										Navegación
									</CardTitle>
									<div className="flex gap-2">
										<CreateLocationDialog
											ubicaciones={ubicaciones}
											setUbicaciones={setUbicaciones}
											tipos={tipos}
											getFullPath={getFullPath}
											procesarPlantilla={procesarPlantilla}
										/>
										<CreateEquipmentDialog
											equipos={equipos}
											setEquipos={setEquipos}
											ubicaciones={ubicaciones}
											marcas={marcas}
										/>
										<CreateBrandDialog marcas={marcas} setMarcas={setMarcas} />
										<ManageTypesDialog tipos={tipos} setTipos={setTipos} />
									</div>
								</div>

								<div className="relative">
									<Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
									<Input
										placeholder="Buscar ubicaciones o equipos..."
										value={searchTerm}
										onChange={(e) => setSearchTerm(e.target.value)}
										className="pl-10 border-green-300 focus:border-green-500"
									/>
								</div>
							</CardHeader>

							<CardContent>
								<Tabs value={activeTab} onValueChange={setActiveTab}>
									<TabsList className="grid w-full grid-cols-2 mb-4">
										<TabsTrigger
											value="ubicaciones"
											className="data-[state=active]:bg-green-100"
										>
											Ubicaciones
										</TabsTrigger>
										<TabsTrigger
											value="equipos"
											className="data-[state=active]:bg-green-100"
										>
											Equipos
										</TabsTrigger>
									</TabsList>

									<TabsContent
										value="ubicaciones"
										className="space-y-2 max-h-96 overflow-y-auto"
									>
										{Object.values(filteredUbicaciones)
											.filter((item) => !item.parentId)
											.map((item) =>
												renderTreeNode(item.id, 0, filteredUbicaciones)
											)}
									</TabsContent>

									<TabsContent
										value="equipos"
										className="space-y-2 max-h-96 overflow-y-auto"
									>
										{Object.values(filteredEquipos).map((equipo) =>
											renderEquipoItem(equipo)
										)}
									</TabsContent>
								</Tabs>
							</CardContent>
						</Card>
					</div>

					{/* Panel derecho - Detalles */}
					<div className="lg:col-span-3">
						{selectedItemData ? (
							selectedType === 'ubicacion' ? (
								<UbicacionDetails
									ubicacion={selectedItemData as UbicacionTecnica}
									ubicaciones={ubicaciones}
									setUbicaciones={setUbicaciones} // Pass setUbicaciones
									equipos={equipos}
									tipos={tipos}
									getFullPath={getFullPath}
									getMarcaNombre={getMarcaNombre}
									getTipoNombre={getTipoNombre}
									procesarPlantilla={procesarPlantilla}
								/>
							) : (
								<EquipoDetails
									equipo={selectedItemData as Equipo}
									ubicaciones={ubicaciones}
									marcas={marcas}
									equipos={equipos}
									setEquipos={setEquipos}
									getFullPath={getFullPath}
									getUbicacionNombre={getUbicacionNombre}
								/>
							)
						) : (
							<Card className="h-96 flex items-center justify-center">
								<div className="text-center text-gray-500">
									<Building className="h-16 w-16 mx-auto mb-4 text-gray-300" />
									<p className="text-lg font-medium">
										Selecciona una ubicación o equipo
									</p>
									<p className="text-sm">
										para ver sus detalles y opciones de gestión
									</p>
								</div>
							</Card>
						)}
					</div>
				</div>
			</div>
		</div>
	);
}

// Componente ComboBox para selección de ubicación padre
function UbicacionComboBox({
	value,
	onValueChange,
	ubicaciones,
	getFullPath,
	placeholder = 'Seleccionar ubicación...',
	excludeId // New prop to exclude the current item from its own parent list
}: {
	value: string;
	onValueChange: (value: string) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
	getFullPath: (id: string) => string;
	placeholder?: string;
	excludeId?: string;
}) {
	const [open, setOpen] = useState(false);

	const ubicacionesList = useMemo(() => {
		return Object.values(ubicaciones)
			.filter((ubicacion) => ubicacion.id !== excludeId) // Exclude the current item
			.map((ubicacion) => ({
				value: ubicacion.id,
				label: `${ubicacion.nombre} (${getFullPath(ubicacion.id)})`
			}));
	}, [ubicaciones, getFullPath, excludeId]);

	const selectedUbicacion =
		value === NONE_SELECTED_VALUE ? null : ubicaciones[value];

	return (
		<Popover open={open} onOpenChange={setOpen}>
			<PopoverTrigger asChild>
				<Button
					variant="outline"
					role="combobox"
					aria-expanded={open}
					className="w-full justify-between bg-transparent"
				>
					{selectedUbicacion ? selectedUbicacion.nombre : placeholder}
					<ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
				</Button>
			</PopoverTrigger>
			<PopoverContent className="w-full p-0">
				<Command>
					<CommandInput placeholder="Buscar ubicación..." />
					<CommandList>
						<CommandEmpty>No se encontraron ubicaciones.</CommandEmpty>
						<CommandGroup>
							<CommandItem
								value={NONE_SELECTED_VALUE}
								onSelect={() => {
									onValueChange(NONE_SELECTED_VALUE);
									setOpen(false);
								}}
							>
								<Check
									className={cn(
										'mr-2 h-4 w-4',
										value === NONE_SELECTED_VALUE ? 'opacity-100' : 'opacity-0'
									)}
								/>
								Sin padre (ubicación raíz)
							</CommandItem>
							{ubicacionesList.map((ubicacion) => (
								<CommandItem
									key={ubicacion.value}
									value={ubicacion.value}
									onSelect={(currentValue) => {
										onValueChange(
											currentValue === value
												? NONE_SELECTED_VALUE
												: currentValue
										);
										setOpen(false);
									}}
								>
									<Check
										className={cn(
											'mr-2 h-4 w-4',
											value === ubicacion.value ? 'opacity-100' : 'opacity-0'
										)}
									/>
									{ubicacion.label}
								</CommandItem>
							))}
						</CommandGroup>
					</CommandList>
				</Command>
			</PopoverContent>
		</Popover>
	);
}

// Componente para inserción rápida tipo Excel
function QuickInsertLocationDialog({
	parentId,
	insertAfter,
	ubicaciones,
	setUbicaciones,
	tipos,
	getFullPath,
	procesarPlantilla
}: {
	parentId?: string;
	insertAfter: string;
	ubicaciones: Record<string, UbicacionTecnica>;
	setUbicaciones: (ubicaciones: Record<string, UbicacionTecnica>) => void;
	tipos: Record<string, TipoUbicacion>;
	getFullPath: (id: string) => string;
	procesarPlantilla: (
		plantilla: string,
		variables: Record<string, string>
	) => string;
}) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<div className="absolute right-2 top-1/2 transform -translate-y-1/2">
			<Dialog open={isOpen} onOpenChange={setIsOpen}>
				<DialogTrigger asChild>
					<Button
						size="sm"
						variant="ghost"
						className="h-6 w-6 p-0 bg-green-100 hover:bg-green-200 text-green-700"
						onClick={(e) => e.stopPropagation()}
					>
						<Plus className="h-3 w-3" />
					</Button>
				</DialogTrigger>
				<UbicacionFormDialogContent
					isOpen={isOpen}
					onClose={() => setIsOpen(false)}
					ubicaciones={ubicaciones}
					setUbicaciones={setUbicaciones}
					tipos={tipos}
					getFullPath={getFullPath}
					procesarPlantilla={procesarPlantilla}
					defaultParentId={parentId}
					insertAfter={insertAfter}
					isQuickInsert={true}
				/>
			</Dialog>
		</div>
	);
}

// Contenido del diálogo de creación/edición de ubicación (reutilizable)
function UbicacionFormDialogContent({
	isOpen,
	onClose,
	ubicaciones,
	setUbicaciones,
	tipos,
	getFullPath,
	procesarPlantilla,
	initialData, // New prop for editing
	defaultParentId,
	insertAfter,
	isQuickInsert = false
}: {
	isOpen: boolean;
	onClose: () => void;
	ubicaciones: Record<string, UbicacionTecnica>;
	setUbicaciones: (ubicaciones: Record<string, UbicacionTecnica>) => void;
	tipos: Record<string, TipoUbicacion>;
	getFullPath: (id: string) => string;
	procesarPlantilla: (
		plantilla: string,
		variables: Record<string, string>
	) => string;
	initialData?: UbicacionTecnica; // Optional for editing
	defaultParentId?: string;
	insertAfter?: string;
	isQuickInsert?: boolean;
}) {
	const [formData, setFormData] = useState({
		tipoId: initialData?.tipoId || '',
		parentId: initialData?.parentId || defaultParentId || NONE_SELECTED_VALUE,
		variables: initialData?.variables || ({} as Record<string, string>)
	});

	// Reset form data when dialog opens or initialData changes
	useEffect(() => {
		if (isOpen) {
			setFormData({
				tipoId: initialData?.tipoId || '',
				parentId:
					initialData?.parentId || defaultParentId || NONE_SELECTED_VALUE,
				variables: initialData?.variables || ({} as Record<string, string>)
			});
		}
	}, [isOpen, initialData, defaultParentId]);

	const selectedTipo = tipos[formData.tipoId];
	const previewNombre =
		selectedTipo && Object.keys(formData.variables).length > 0
			? procesarPlantilla(selectedTipo.plantillaNombre, formData.variables)
			: '';
	const previewCodigo =
		selectedTipo && Object.keys(formData.variables).length > 0
			? procesarPlantilla(selectedTipo.plantillaCodigo, formData.variables)
			: '';

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		if (!selectedTipo) return;

		const newId = initialData?.id || `${formData.tipoId}-${Date.now()}`;
		const oldParentId = initialData?.parentId;

		const updatedUbicacion: UbicacionTecnica = {
			id: newId,
			codigo: previewCodigo,
			nombre: previewNombre,
			tipoId: formData.tipoId,
			parentId:
				formData.parentId === NONE_SELECTED_VALUE
					? undefined
					: formData.parentId,
			childIds: initialData?.childIds || [], // Keep existing children for edits
			estado: initialData?.estado || 'activa', // Keep existing status for edits
			variables: formData.variables
		};

		const newUbicaciones = { ...ubicaciones };

		// Handle parent changes for existing locations
		if (initialData && oldParentId !== updatedUbicacion.parentId) {
			// Remove from old parent's children
			if (oldParentId && newUbicaciones[oldParentId]) {
				newUbicaciones[oldParentId] = {
					...newUbicaciones[oldParentId],
					childIds: newUbicaciones[oldParentId].childIds.filter(
						(childId) => childId !== newId
					)
				};
			}
			// Add to new parent's children
			if (
				updatedUbicacion.parentId &&
				newUbicaciones[updatedUbicacion.parentId]
			) {
				newUbicaciones[updatedUbicacion.parentId] = {
					...newUbicaciones[updatedUbicacion.parentId],
					childIds: [
						...newUbicaciones[updatedUbicacion.parentId].childIds,
						newId
					]
				};
			}
		} else if (
			!initialData &&
			updatedUbicacion.parentId &&
			newUbicaciones[updatedUbicacion.parentId]
		) {
			// For new locations, add to parent's children
			const parent = newUbicaciones[updatedUbicacion.parentId];
			const newChildIds = [...parent.childIds];

			if (insertAfter && isQuickInsert) {
				const insertIndex = newChildIds.indexOf(insertAfter);
				if (insertIndex !== -1) {
					newChildIds.splice(insertIndex + 1, 0, newId);
				} else {
					newChildIds.push(newId);
				}
			} else {
				newChildIds.push(newId);
			}

			newUbicaciones[updatedUbicacion.parentId] = {
				...parent,
				childIds: newChildIds
			};
		}

		newUbicaciones[newId] = updatedUbicacion;
		setUbicaciones(newUbicaciones);
		onClose();
	};

	const handleVariableChange = (variableName: string, value: string) => {
		setFormData((prev) => ({
			...prev,
			variables: {
				...prev.variables,
				[variableName]: value
			}
		}));
	};

	return (
		<DialogContent className="max-w-lg max-h-[80vh] overflow-y-auto">
			<DialogHeader>
				<DialogTitle>
					{initialData
						? 'Editar Ubicación'
						: isQuickInsert
						? 'Insertar Nueva Ubicación'
						: 'Crear Nueva Ubicación'}
				</DialogTitle>
				{initialData && (
					<p className="text-sm text-gray-600">{initialData.nombre}</p>
				)}
				{!initialData && defaultParentId && (
					<p className="text-sm text-gray-600">
						Padre: {ubicaciones[defaultParentId]?.nombre} (
						{getFullPath(defaultParentId)})
					</p>
				)}
			</DialogHeader>
			<form onSubmit={handleSubmit} className="space-y-4">
				<div>
					<Label htmlFor="tipoId">Tipo de Ubicación</Label>
					<Select
						value={formData.tipoId}
						onValueChange={(value) =>
							setFormData((prev) => ({ ...prev, tipoId: value, variables: {} }))
						}
					>
						<SelectTrigger>
							<SelectValue placeholder="Seleccionar tipo" />
						</SelectTrigger>
						<SelectContent>
							{Object.values(tipos).map((tipo) => (
								<SelectItem key={tipo.id} value={tipo.id}>
									{tipo.nombre} - {tipo.descripcion}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</div>

				{!isQuickInsert && (
					<div>
						<Label>Ubicación Padre</Label>
						<UbicacionComboBox
							value={formData.parentId}
							onValueChange={(value) =>
								setFormData((prev) => ({ ...prev, parentId: value }))
							}
							ubicaciones={ubicaciones}
							getFullPath={getFullPath}
							placeholder="Seleccionar ubicación padre"
							excludeId={initialData?.id} // Exclude current location from its own parent list
						/>
					</div>
				)}

				{selectedTipo && (
					<>
						<Separator />
						<div className="space-y-3">
							<Label className="text-sm font-medium">
								Variables del Tipo "{selectedTipo.nombre}"
							</Label>
							{selectedTipo.variables.map((variable) => (
								<div key={variable}>
									<Label htmlFor={variable} className="text-sm capitalize">
										{variable}
									</Label>
									<Input
										id={variable}
										value={formData.variables[variable] || ''}
										onChange={(e) =>
											handleVariableChange(variable, e.target.value)
										}
										placeholder={`Ingrese ${variable}`}
										required
									/>
								</div>
							))}
						</div>

						{previewNombre && previewCodigo && (
							<>
								<Separator />
								<div className="space-y-2 bg-green-50 p-3 rounded">
									<Label className="text-sm font-medium text-green-800">
										Vista Previa
									</Label>
									<div className="space-y-1">
										<p className="text-sm">
											<strong>Nombre:</strong> {previewNombre}
										</p>
										<p className="text-sm">
											<strong>Código:</strong> {previewCodigo}
										</p>
									</div>
								</div>
							</>
						)}
					</>
				)}

				<div className="flex justify-end gap-2 pt-4">
					<Button type="button" variant="outline" onClick={onClose}>
						Cancelar
					</Button>
					<Button
						type="submit"
						className="bg-green-700 hover:bg-green-800"
						disabled={
							!selectedTipo ||
							selectedTipo.variables.some((v) => !formData.variables[v])
						}
					>
						{initialData
							? 'Guardar Cambios'
							: isQuickInsert
							? 'Insertar'
							: 'Crear'}{' '}
						Ubicación
					</Button>
				</div>
			</form>
		</DialogContent>
	);
}

// Diálogo principal para crear nueva ubicación
function CreateLocationDialog({
	ubicaciones,
	setUbicaciones,
	tipos,
	getFullPath,
	procesarPlantilla
}: {
	ubicaciones: Record<string, UbicacionTecnica>;
	setUbicaciones: (ubicaciones: Record<string, UbicacionTecnica>) => void;
	tipos: Record<string, TipoUbicacion>;
	getFullPath: (id: string) => string;
	procesarPlantilla: (
		plantilla: string,
		variables: Record<string, string>
	) => string;
}) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button size="sm" className="bg-green-700 hover:bg-green-800">
					<Plus className="h-4 w-4 mr-1" />
					Ubicación
				</Button>
			</DialogTrigger>
			<UbicacionFormDialogContent
				isOpen={isOpen}
				onClose={() => setIsOpen(false)}
				ubicaciones={ubicaciones}
				setUbicaciones={setUbicaciones}
				tipos={tipos}
				getFullPath={getFullPath}
				procesarPlantilla={procesarPlantilla}
			/>
		</Dialog>
	);
}

// Diálogo para editar ubicación
function EditLocationDialog({
	ubicacion,
	ubicaciones,
	setUbicaciones,
	tipos,
	getFullPath,
	procesarPlantilla
}: {
	ubicacion: UbicacionTecnica;
	ubicaciones: Record<string, UbicacionTecnica>;
	setUbicaciones: (ubicaciones: Record<string, UbicacionTecnica>) => void;
	tipos: Record<string, TipoUbicacion>;
	getFullPath: (id: string) => string;
	procesarPlantilla: (
		plantilla: string,
		variables: Record<string, string>
	) => string;
}) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button
					variant="outline"
					size="sm"
					className="border-green-300 text-green-700 hover:bg-green-50 bg-transparent"
				>
					<Edit className="h-4 w-4 mr-1" />
					Editar
				</Button>
			</DialogTrigger>
			<UbicacionFormDialogContent
				isOpen={isOpen}
				onClose={() => setIsOpen(false)}
				ubicaciones={ubicaciones}
				setUbicaciones={setUbicaciones}
				tipos={tipos}
				getFullPath={getFullPath}
				procesarPlantilla={procesarPlantilla}
				initialData={ubicacion}
			/>
		</Dialog>
	);
}

// Diálogo para gestionar tipos de ubicación
function ManageTypesDialog({
	tipos,
	setTipos
}: {
	tipos: Record<string, TipoUbicacion>;
	setTipos: (tipos: Record<string, TipoUbicacion>) => void;
}) {
	const [isOpen, setIsOpen] = useState(false);
	const [formData, setFormData] = useState({
		nombre: '',
		plantillaNombre: '',
		plantillaCodigo: '',
		descripcion: '',
		variables: ['']
	});

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		const newId = `tipo-${Date.now()}`;
		const newTipo: TipoUbicacion = {
			id: newId,
			nombre: formData.nombre,
			plantillaNombre: formData.plantillaNombre,
			plantillaCodigo: formData.plantillaCodigo,
			descripcion: formData.descripcion,
			variables: formData.variables.filter((v) => v.trim() !== '')
		};

		setTipos({ ...tipos, [newId]: newTipo });
		setIsOpen(false);
		setFormData({
			nombre: '',
			plantillaNombre: '',
			plantillaCodigo: '',
			descripcion: '',
			variables: ['']
		});
	};

	const addVariable = () => {
		setFormData((prev) => ({
			...prev,
			variables: [...prev.variables, '']
		}));
	};

	const updateVariable = (index: number, value: string) => {
		setFormData((prev) => ({
			...prev,
			variables: prev.variables.map((v, i) => (i === index ? value : v))
		}));
	};

	const removeVariable = (index: number) => {
		setFormData((prev) => ({
			...prev,
			variables: prev.variables.filter((_, i) => i !== index)
		}));
	};

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button
					size="sm"
					variant="outline"
					className="border-green-300 text-green-700 hover:bg-green-50 bg-transparent"
				>
					<Settings className="h-4 w-4 mr-1" />
					Tipos
				</Button>
			</DialogTrigger>
			<DialogContent className="max-w-lg max-h-[80vh] overflow-y-auto">
				<DialogHeader>
					<DialogTitle>Gestionar Tipos de Ubicación</DialogTitle>
				</DialogHeader>

				<Tabs defaultValue="existing" className="w-full">
					<TabsList className="grid w-full grid-cols-2">
						<TabsTrigger value="existing">Tipos Existentes</TabsTrigger>
						<TabsTrigger value="new">Crear Nuevo</TabsTrigger>
					</TabsList>

					<TabsContent
						value="existing"
						className="space-y-3 max-h-60 overflow-y-auto"
					>
						{Object.values(tipos).map((tipo) => (
							<div key={tipo.id} className="p-3 border rounded">
								<div className="flex justify-between items-start">
									<div>
										<h4 className="font-medium">{tipo.nombre}</h4>
										<p className="text-sm text-gray-600">{tipo.descripcion}</p>
										<div className="text-xs text-gray-500 mt-1">
											<p>Nombre: {tipo.plantillaNombre}</p>
											<p>Código: {tipo.plantillaCodigo}</p>
											<p>Variables: {tipo.variables.join(', ')}</p>
										</div>
									</div>
								</div>
							</div>
						))}
					</TabsContent>

					<TabsContent value="new">
						<form onSubmit={handleSubmit} className="space-y-4">
							<div>
								<Label htmlFor="nombre">Nombre del Tipo</Label>
								<Input
									id="nombre"
									value={formData.nombre}
									onChange={(e) =>
										setFormData((prev) => ({ ...prev, nombre: e.target.value }))
									}
									placeholder="ej: Aula, Laboratorio"
									required
								/>
							</div>

							<div>
								<Label htmlFor="descripcion">Descripción</Label>
								<Input
									id="descripcion"
									value={formData.descripcion}
									onChange={(e) =>
										setFormData((prev) => ({
											...prev,
											descripcion: e.target.value
										}))
									}
									placeholder="Breve descripción del tipo"
								/>
							</div>

							<div>
								<Label>Variables</Label>
								<div className="space-y-2">
									{formData.variables.map((variable, index) => (
										<div key={index} className="flex gap-2">
											<Input
												value={variable}
												onChange={(e) => updateVariable(index, e.target.value)}
												placeholder="nombre de variable"
											/>
											<Button
												type="button"
												variant="outline"
												size="sm"
												onClick={() => removeVariable(index)}
												disabled={formData.variables.length === 1}
											>
												×
											</Button>
										</div>
									))}
									<Button
										type="button"
										variant="outline"
										size="sm"
										onClick={addVariable}
									>
										+ Agregar Variable
									</Button>
								</div>
								<p className="text-xs text-gray-500 mt-1">
									Las variables se usan en las plantillas con la sintaxis{' '}
									{'{variable}'}
								</p>
							</div>

							<div>
								<Label htmlFor="plantillaNombre">Plantilla de Nombre</Label>
								<Input
									id="plantillaNombre"
									value={formData.plantillaNombre}
									onChange={(e) =>
										setFormData((prev) => ({
											...prev,
											plantillaNombre: e.target.value
										}))
									}
									placeholder="ej: Salón {numero}"
									required
								/>
							</div>

							<div>
								<Label htmlFor="plantillaCodigo">Plantilla de Código</Label>
								<Input
									id="plantillaCodigo"
									value={formData.plantillaCodigo}
									onChange={(e) =>
										setFormData((prev) => ({
											...prev,
											plantillaCodigo: e.target.value
										}))
									}
									placeholder="ej: S-{numero}"
									required
								/>
							</div>

							<div className="flex justify-end gap-2 pt-4">
								<Button
									type="button"
									variant="outline"
									onClick={() => setIsOpen(false)}
								>
									Cancelar
								</Button>
								<Button
									type="submit"
									className="bg-green-700 hover:bg-green-800"
								>
									Crear Tipo
								</Button>
							</div>
						</form>
					</TabsContent>
				</Tabs>
			</DialogContent>
		</Dialog>
	);
}

// Componente para mostrar detalles de ubicación (actualizado)
function UbicacionDetails({
	ubicacion,
	ubicaciones,
	setUbicaciones, // Added setUbicaciones
	equipos,
	tipos,
	getFullPath,
	getMarcaNombre,
	getTipoNombre,
	procesarPlantilla
}: {
	ubicacion: UbicacionTecnica;
	ubicaciones: Record<string, UbicacionTecnica>;
	setUbicaciones: (ubicaciones: Record<string, UbicacionTecnica>) => void; // Added
	equipos: Record<string, Equipo>;
	tipos: Record<string, TipoUbicacion>;
	getFullPath: (id: string) => string;
	getMarcaNombre: (marcaId: string) => string;
	getTipoNombre: (tipoId: string) => string;
	procesarPlantilla: (
		plantilla: string,
		variables: Record<string, string>
	) => string;
}) {
	const tipo = tipos[ubicacion.tipoId];
	const Icon = tipoIcons[ubicacion.tipoId] || MapPin;

	// Equipos físicamente en esta ubicación
	const equiposFisicos = Object.values(equipos).filter(
		(eq) => eq.ubicacionFisicaId === ubicacion.id
	);

	// Equipos que operan en esta ubicación
	const equiposOperativos = Object.values(equipos).filter((eq) =>
		eq.ubicacionesOperativas.includes(ubicacion.id)
	);

	return (
		<Card>
			<CardHeader>
				<div className="flex items-center gap-3">
					<Icon className="h-8 w-8 text-green-700" />
					<div className="flex-1">
						<CardTitle className="text-xl text-green-800">
							{ubicacion.nombre}
						</CardTitle>
						<p className="text-sm text-gray-600 mt-1">
							{getFullPath(ubicacion.id)}
						</p>
						<div className="flex items-center gap-2 mt-1">
							<Badge variant="outline" className="text-xs">
								{getTipoNombre(ubicacion.tipoId)}
							</Badge>
							{ubicacion.estado && (
								<Badge
									className={`text-xs ${
										estadoUbicacionColors[ubicacion.estado]
									}`}
								>
									{ubicacion.estado.replace(/_/g, ' ')}
								</Badge>
							)}
						</div>
					</div>
					<EditLocationDialog
						ubicacion={ubicacion}
						ubicaciones={ubicaciones}
						setUbicaciones={setUbicaciones}
						tipos={tipos}
						getFullPath={getFullPath}
						procesarPlantilla={procesarPlantilla}
					/>
				</div>
			</CardHeader>

			<CardContent className="space-y-6">
				<div className="grid grid-cols-2 gap-4">
					<div>
						<Label className="text-sm font-medium text-gray-700">
							Código Técnico
						</Label>
						<p className="text-sm mt-1 font-mono bg-gray-50 p-2 rounded">
							{ubicacion.codigo}
						</p>
					</div>
					<div>
						<Label className="text-sm font-medium text-gray-700">
							Tipo de Ubicación
						</Label>
						<p className="text-sm mt-1">{getTipoNombre(ubicacion.tipoId)}</p>
					</div>
				</div>

				{ubicacion.variables && Object.keys(ubicacion.variables).length > 0 && (
					<div>
						<Label className="text-sm font-medium text-gray-700 mb-2 block">
							Variables del Tipo
						</Label>
						<div className="grid grid-cols-2 gap-2">
							{Object.entries(ubicacion.variables).map(([key, value]) => (
								<div key={key} className="bg-gray-50 p-2 rounded">
									<span className="text-xs text-gray-600 capitalize">
										{key}:
									</span>
									<span className="text-sm font-medium ml-1">{value}</span>
								</div>
							))}
						</div>
					</div>
				)}

				{tipo && (
					<div>
						<Label className="text-sm font-medium text-gray-700 mb-2 block">
							Plantillas del Tipo
						</Label>
						<div className="bg-blue-50 p-3 rounded border border-blue-200">
							<p className="text-sm">
								<strong>Nombre:</strong> {tipo.plantillaNombre}
							</p>
							<p className="text-sm">
								<strong>Código:</strong> {tipo.plantillaCodigo}
							</p>
							<p className="text-sm text-gray-600 mt-1">{tipo.descripcion}</p>
						</div>
					</div>
				)}

				{ubicacion.childIds.length > 0 && (
					<div>
						<Label className="text-sm font-medium text-gray-700 mb-2 block">
							Ubicaciones Hijas ({ubicacion.childIds.length})
						</Label>
						<div className="space-y-2 max-h-32 overflow-y-auto">
							{ubicacion.childIds.map((childId) => {
								const child = ubicaciones[childId];
								if (!child) return null;
								const childTipo = tipos[child.tipoId];
								const ChildIcon = tipoIcons[child.tipoId] || MapPin;
								return (
									<div
										key={childId}
										className="flex items-center gap-2 p-2 bg-gray-50 rounded"
									>
										<ChildIcon className="h-4 w-4 text-green-600" />
										<span className="text-sm flex-1">{child.nombre}</span>
										<Badge variant="outline" className="text-xs">
											{child.codigo}
										</Badge>
										<Badge variant="outline" className="text-xs text-gray-600">
											{childTipo?.nombre}
										</Badge>
									</div>
								);
							})}
						</div>
					</div>
				)}

				<Separator />

				<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
					<div>
						<Label className="text-sm font-medium text-gray-700 mb-2 block">
							📍 Equipos Instalados Físicamente ({equiposFisicos.length})
						</Label>
						<div className="space-y-2 max-h-40 overflow-y-auto">
							{equiposFisicos.length > 0 ? (
								equiposFisicos.map((equipo) => (
									<div
										key={equipo.id}
										className="flex items-center gap-2 p-2 bg-blue-50 rounded border border-blue-200"
									>
										<Wrench className="h-4 w-4 text-blue-600" />
										<div className="flex-1 min-w-0">
											<span className="text-sm font-medium">
												{equipo.nombre}
											</span>
											<div className="text-xs text-gray-600">
												{getMarcaNombre(equipo.marcaId)}
											</div>
										</div>
										<Badge
											className={`text-xs ${estadoEquipoColors[equipo.estado]}`}
										>
											{equipo.estado.replace(/_/g, ' ')}
										</Badge>
									</div>
								))
							) : (
								<p className="text-sm text-gray-500 italic">
									No hay equipos instalados físicamente
								</p>
							)}
						</div>
					</div>

					<div>
						<Label className="text-sm font-medium text-gray-700 mb-2 block">
							⚙️ Equipos Operando Aquí ({equiposOperativos.length})
						</Label>
						<div className="space-y-2 max-h-40 overflow-y-auto">
							{equiposOperativos.length > 0 ? (
								equiposOperativos.map((equipo) => (
									<div
										key={equipo.id}
										className="flex items-center gap-2 p-2 bg-green-50 rounded border border-green-200"
									>
										<Wrench className="h-4 w-4 text-green-600" />
										<div className="flex-1 min-w-0">
											<span className="text-sm font-medium">
												{equipo.nombre}
											</span>
											<div className="text-xs text-gray-600">
												Físicamente en:{' '}
												{equipo.ubicacionFisicaId
													? ubicaciones[equipo.ubicacionFisicaId]?.nombre
													: 'Sin asignar'}
											</div>
										</div>
										<Badge
											className={`text-xs ${estadoEquipoColors[equipo.estado]}`}
										>
											{equipo.estado.replace(/_/g, ' ')}
										</Badge>
									</div>
								))
							) : (
								<p className="text-sm text-gray-500 italic">
									No hay equipos operando en esta ubicación
								</p>
							)}
						</div>
					</div>
				</div>
			</CardContent>
		</Card>
	);
}

// Contenido del diálogo de creación/edición de equipo (reutilizable)
function EquipoFormDialogContent({
	isOpen,
	onClose,
	equipos,
	setEquipos,
	ubicaciones,
	marcas,
	initialData // Optional for editing
}: {
	isOpen: boolean;
	onClose: () => void;
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
	marcas: Record<string, Marca>;
	initialData?: Equipo; // Optional for editing
}) {
	const [formData, setFormData] = useState({
		codigo: initialData?.codigo || '',
		nombre: initialData?.nombre || '',
		serial: initialData?.serial || '',
		marcaId: initialData?.marcaId || '',
		descripcion: initialData?.descripcion || '',
		ubicacionFisicaId: initialData?.ubicacionFisicaId || NONE_SELECTED_VALUE,
		estado: initialData?.estado || ('en_inventario' as Equipo['estado'])
	});

	// Reset form data when dialog opens or initialData changes
	useEffect(() => {
		if (isOpen) {
			setFormData({
				codigo: initialData?.codigo || '',
				nombre: initialData?.nombre || '',
				serial: initialData?.serial || '',
				marcaId: initialData?.marcaId || '',
				descripcion: initialData?.descripcion || '',
				ubicacionFisicaId:
					initialData?.ubicacionFisicaId || NONE_SELECTED_VALUE,
				estado: initialData?.estado || ('en_inventario' as Equipo['estado'])
			});
		}
	}, [isOpen, initialData]);

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		const newId = initialData?.id || `eq-${Date.now()}`;
		const updatedEquipo: Equipo = {
			id: newId,
			codigo: formData.codigo,
			nombre: formData.nombre,
			serial: formData.serial,
			marcaId: formData.marcaId,
			descripcion: formData.descripcion,
			ubicacionFisicaId:
				formData.ubicacionFisicaId === NONE_SELECTED_VALUE
					? undefined
					: formData.ubicacionFisicaId,
			ubicacionesOperativas: initialData?.ubicacionesOperativas || [], // Keep existing for edits
			estado: formData.estado,
			ubicacionDestinoId: initialData?.ubicacionDestinoId, // Keep existing for edits
			fechaMudanza: initialData?.fechaMudanza, // Keep existing for edits
			observaciones: initialData?.observaciones // Keep existing for edits
		};

		setEquipos({ ...equipos, [newId]: updatedEquipo });
		onClose();
	};

	return (
		<DialogContent className="max-w-lg max-h-[80vh] overflow-y-auto">
			<DialogHeader>
				<DialogTitle>
					{initialData ? 'Editar Equipo' : 'Crear Nuevo Equipo'}
				</DialogTitle>
				{initialData && (
					<p className="text-sm text-gray-600">{initialData.nombre}</p>
				)}
			</DialogHeader>
			<form onSubmit={handleSubmit} className="space-y-4">
				<div className="grid grid-cols-2 gap-4">
					<div>
						<Label htmlFor="codigo">Código del Equipo</Label>
						<Input
							id="codigo"
							value={formData.codigo}
							onChange={(e) =>
								setFormData({ ...formData, codigo: e.target.value })
							}
							placeholder="ej: AC-001"
							required
						/>
					</div>
					<div>
						<Label htmlFor="serial">Número de Serie</Label>
						<Input
							id="serial"
							value={formData.serial}
							onChange={(e) =>
								setFormData({ ...formData, serial: e.target.value })
							}
							placeholder="Número de serie"
							required
						/>
					</div>
				</div>

				<div>
					<Label htmlFor="nombre">Nombre del Equipo</Label>
					<Input
						id="nombre"
						value={formData.nombre}
						onChange={(e) =>
							setFormData({ ...formData, nombre: e.target.value })
						}
						placeholder="Nombre descriptivo"
						required
					/>
				</div>

				<div className="grid grid-cols-2 gap-4">
					<div>
						<Label htmlFor="marcaId">Marca</Label>
						<Select
							value={formData.marcaId}
							onValueChange={(value) =>
								setFormData({ ...formData, marcaId: value })
							}
						>
							<SelectTrigger>
								<SelectValue placeholder="Seleccionar marca" />
							</SelectTrigger>
							<SelectContent>
								{Object.values(marcas).map((marca) => (
									<SelectItem key={marca.id} value={marca.id}>
										{marca.nombre}
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</div>
					<div>
						<Label htmlFor="estado">Estado Inicial</Label>
						<Select
							value={formData.estado}
							onValueChange={(value: Equipo['estado']) =>
								setFormData({ ...formData, estado: value })
							}
						>
							<SelectTrigger>
								<SelectValue />
							</SelectTrigger>
							<SelectContent>
								<SelectItem value="en_inventario">En Inventario</SelectItem>
								<SelectItem value="instalado">Instalado</SelectItem>
								<SelectItem value="en_mantenimiento">
									En Mantenimiento
								</SelectItem>
								<SelectItem value="por_hacer_mantenimiento">
									Por Hacer Mantenimiento
								</SelectItem>
								<SelectItem value="por_mudar">Por Mudar</SelectItem>
							</SelectContent>
						</Select>
					</div>
				</div>

				<div>
					<Label htmlFor="ubicacionFisicaId">Ubicación Física (Opcional)</Label>
					<Select
						value={formData.ubicacionFisicaId}
						onValueChange={(value) =>
							setFormData({ ...formData, ubicacionFisicaId: value })
						}
					>
						<SelectTrigger>
							<SelectValue placeholder="Seleccionar ubicación física" />
						</SelectTrigger>
						<SelectContent>
							<SelectItem value={NONE_SELECTED_VALUE}>
								Sin asignar (en inventario)
							</SelectItem>
							{Object.values(ubicaciones).map((ubicacion) => (
								<SelectItem key={ubicacion.id} value={ubicacion.id}>
									{ubicacion.nombre}
								</SelectItem>
							))}
						</SelectContent>
					</Select>
				</div>

				<div>
					<Label htmlFor="descripcion">Descripción</Label>
					<Textarea
						id="descripcion"
						value={formData.descripcion}
						onChange={(e) =>
							setFormData({ ...formData, descripcion: e.target.value })
						}
						placeholder="Descripción del equipo"
						rows={3}
					/>
				</div>

				<div className="flex justify-end gap-2 pt-4">
					<Button type="button" variant="outline" onClick={onClose}>
						Cancelar
					</Button>
					<Button type="submit" className="bg-green-700 hover:bg-green-800">
						{initialData ? 'Guardar Cambios' : 'Crear Equipo'}
					</Button>
				</div>
			</form>
		</DialogContent>
	);
}

// Diálogo principal para crear nuevo equipo
function CreateEquipmentDialog({
	equipos,
	setEquipos,
	ubicaciones,
	marcas
}: {
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
	marcas: Record<string, Marca>;
}) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button size="sm" className="bg-green-700 hover:bg-green-800">
					<Plus className="h-4 w-4 mr-1" />
					Equipo
				</Button>
			</DialogTrigger>
			<EquipoFormDialogContent
				isOpen={isOpen}
				onClose={() => setIsOpen(false)}
				equipos={equipos}
				setEquipos={setEquipos}
				ubicaciones={ubicaciones}
				marcas={marcas}
			/>
		</Dialog>
	);
}

// Diálogo para editar equipo
function EditEquipmentDialog({
	equipo,
	equipos,
	setEquipos,
	ubicaciones,
	marcas
}: {
	equipo: Equipo;
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
	marcas: Record<string, Marca>;
}) {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button
					variant="outline"
					size="sm"
					className="border-green-300 text-green-700 hover:bg-green-50 bg-transparent"
				>
					<Edit className="h-4 w-4 mr-1" />
					Editar
				</Button>
			</DialogTrigger>
			<EquipoFormDialogContent
				isOpen={isOpen}
				onClose={() => setIsOpen(false)}
				equipos={equipos}
				setEquipos={setEquipos}
				ubicaciones={ubicaciones}
				marcas={marcas}
				initialData={equipo}
			/>
		</Dialog>
	);
}

// Diálogo para crear nueva marca
function CreateBrandDialog({
	marcas,
	setMarcas
}: {
	marcas: Record<string, Marca>;
	setMarcas: (marcas: Record<string, Marca>) => void;
}) {
	const [isOpen, setIsOpen] = useState(false);
	const [formData, setFormData] = useState({
		nombre: '',
		descripcion: ''
	});

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		const newId = `marca-${Date.now()}`;
		const newMarca: Marca = {
			id: newId,
			nombre: formData.nombre,
			descripcion: formData.descripcion
		};

		setMarcas({ ...marcas, [newId]: newMarca });
		setIsOpen(false);
		setFormData({ nombre: '', descripcion: '' });
	};

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button
					size="sm"
					variant="outline"
					className="border-green-300 text-green-700 hover:bg-green-50 bg-transparent"
				>
					<Plus className="h-4 w-4 mr-1" />
					Marca
				</Button>
			</DialogTrigger>
			<DialogContent className="max-w-md">
				<DialogHeader>
					<DialogTitle>Crear Nueva Marca</DialogTitle>
				</DialogHeader>
				<form onSubmit={handleSubmit} className="space-y-4">
					<div>
						<Label htmlFor="nombre">Nombre de la Marca</Label>
						<Input
							id="nombre"
							value={formData.nombre}
							onChange={(e) =>
								setFormData({ ...formData, nombre: e.target.value })
							}
							placeholder="ej: Samsung, Dell, HP"
							required
						/>
					</div>

					<div>
						<Label htmlFor="descripcion">Descripción (Opcional)</Label>
						<Textarea
							id="descripcion"
							value={formData.descripcion}
							onChange={(e) =>
								setFormData({ ...formData, descripcion: e.target.value })
							}
							placeholder="Breve descripción de la marca"
							rows={2}
						/>
					</div>

					<div className="flex justify-end gap-2 pt-4">
						<Button
							type="button"
							variant="outline"
							onClick={() => setIsOpen(false)}
						>
							Cancelar
						</Button>
						<Button type="submit" className="bg-green-700 hover:bg-green-800">
							Crear Marca
						</Button>
					</div>
				</form>
			</DialogContent>
		</Dialog>
	);
}

// Diálogo para asignar ubicaciones
function AssignLocationDialog({
	equipo,
	equipos,
	setEquipos,
	ubicaciones
}: {
	equipo: Equipo;
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
}) {
	const [isOpen, setIsOpen] = useState(false);
	const [ubicacionFisica, setUbicacionFisica] = useState(
		equipo.ubicacionFisicaId || NONE_SELECTED_VALUE
	);
	const [ubicacionesOperativas, setUbicacionesOperativas] = useState<string[]>(
		equipo.ubicacionesOperativas
	);

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		const updatedEquipo: Equipo = {
			...equipo,
			ubicacionFisicaId:
				ubicacionFisica === NONE_SELECTED_VALUE ? undefined : ubicacionFisica,
			ubicacionesOperativas: ubicacionesOperativas,
			estado:
				ubicacionFisica !== NONE_SELECTED_VALUE ? 'instalado' : 'en_inventario'
		};

		setEquipos({ ...equipos, [equipo.id]: updatedEquipo });
		setIsOpen(false);
	};

	const toggleUbicacionOperativa = (ubicacionId: string) => {
		if (ubicacionesOperativas.includes(ubicacionId)) {
			setUbicacionesOperativas(
				ubicacionesOperativas.filter((id) => id !== ubicacionId)
			);
		} else {
			setUbicacionesOperativas([...ubicacionesOperativas, ubicacionId]);
		}
	};

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button className="bg-green-700 hover:bg-green-800">
					<MapPin className="h-4 w-4 mr-2" />
					Asignar Ubicaciones
				</Button>
			</DialogTrigger>
			<DialogContent className="max-w-lg max-h-[80vh] overflow-y-auto">
				<DialogHeader>
					<DialogTitle>Asignar Ubicaciones - {equipo.nombre}</DialogTitle>
				</DialogHeader>
				<form onSubmit={handleSubmit} className="space-y-6">
					<div>
						<Label className="text-sm font-medium text-gray-700 mb-3 block">
							📍 Ubicación Física (Donde está instalado)
						</Label>
						<Select value={ubicacionFisica} onValueChange={setUbicacionFisica}>
							<SelectTrigger>
								<SelectValue placeholder="Seleccionar ubicación física" />
							</SelectTrigger>
							<SelectContent>
								<SelectItem value={NONE_SELECTED_VALUE}>
									Sin asignar (en inventario)
								</SelectItem>
								{Object.values(ubicaciones).map((ubicacion) => (
									<SelectItem key={ubicacion.id} value={ubicacion.id}>
										{ubicacion.nombre} ({ubicacion.codigo})
									</SelectItem>
								))}
							</SelectContent>
						</Select>
					</div>

					<Separator />

					<div>
						<Label className="text-sm font-medium text-gray-700 mb-3 block">
							⚙️ Ubicaciones Operativas (Donde funciona/opera)
						</Label>
						<div className="space-y-2 max-h-60 overflow-y-auto border rounded p-3">
							{Object.values(ubicaciones).map((ubicacion) => (
								<div key={ubicacion.id} className="flex items-center space-x-2">
									<input
										type="checkbox"
										id={`op-${ubicacion.id}`}
										checked={ubicacionesOperativas.includes(ubicacion.id)}
										onChange={() => toggleUbicacionOperativa(ubicacion.id)}
										className="rounded border-gray-300 text-green-600 focus:ring-green-500"
									/>
									<label
										htmlFor={`op-${ubicacion.id}`}
										className="text-sm flex-1 cursor-pointer"
									>
										{ubicacion.nombre} ({ubicacion.codigo})
									</label>
								</div>
							))}
						</div>
						<p className="text-xs text-gray-500 mt-2">
							Selecciona todas las ubicaciones donde este equipo opera o
							funciona
						</p>
					</div>

					<div className="flex justify-end gap-2 pt-4">
						<Button
							type="button"
							variant="outline"
							onClick={() => setIsOpen(false)}
						>
							Cancelar
						</Button>
						<Button type="submit" className="bg-green-700 hover:bg-green-800">
							Guardar Asignaciones
						</Button>
					</div>
				</form>
			</DialogContent>
		</Dialog>
	);
}

// Diálogo para programar mudanza
function ScheduleMoveDialog({
	equipo,
	equipos,
	setEquipos,
	ubicaciones
}: {
	equipo: Equipo;
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	ubicaciones: Record<string, UbicacionTecnica>;
}) {
	const [isOpen, setIsOpen] = useState(false);
	const [ubicacionDestino, setUbicacionDestino] = useState(
		equipo.ubicacionDestinoId || NONE_SELECTED_VALUE
	);
	const [fechaMudanza, setFechaMudanza] = useState(equipo.fechaMudanza || '');
	const [observaciones, setObservaciones] = useState(
		equipo.observaciones || ''
	);

	const handleSubmit = (e: React.FormEvent) => {
		e.preventDefault();

		const updatedEquipo: Equipo = {
			...equipo,
			estado: 'por_mudar',
			ubicacionDestinoId:
				ubicacionDestino === NONE_SELECTED_VALUE ? undefined : ubicacionDestino,
			fechaMudanza: fechaMudanza || undefined,
			observaciones: observaciones || undefined
		};

		setEquipos({ ...equipos, [equipo.id]: updatedEquipo });
		setIsOpen(false);
	};

	const confirmarMudanza = () => {
		const updatedEquipo: Equipo = {
			...equipo,
			ubicacionFisicaId: equipo.ubicacionDestinoId,
			estado: 'instalado',
			ubicacionDestinoId: undefined,
			fechaMudanza: undefined,
			observaciones: undefined
		};

		setEquipos({ ...equipos, [equipo.id]: updatedEquipo });
		setIsOpen(false);
	};

	return (
		<Dialog open={isOpen} onOpenChange={setIsOpen}>
			<DialogTrigger asChild>
				<Button
					variant="outline"
					className="border-blue-300 text-blue-700 hover:bg-blue-50 bg-transparent"
				>
					<Truck className="h-4 w-4 mr-2" />
					{equipo.estado === 'por_mudar'
						? 'Gestionar Mudanza'
						: 'Programar Mudanza'}
				</Button>
			</DialogTrigger>
			<DialogContent className="max-w-md">
				<DialogHeader>
					<DialogTitle>
						{equipo.estado === 'por_mudar'
							? 'Gestionar Mudanza'
							: 'Programar Mudanza'}
					</DialogTitle>
				</DialogHeader>

				{equipo.estado === 'por_mudar' ? (
					<div className="space-y-4">
						<div className="p-4 bg-blue-50 rounded border border-blue-200">
							<h4 className="font-medium text-blue-800 mb-2">
								Mudanza Programada
							</h4>
							<p className="text-sm text-blue-700">
								<strong>Destino:</strong>{' '}
								{equipo.ubicacionDestinoId
									? ubicaciones[equipo.ubicacionDestinoId]?.nombre
									: 'N/A'}
							</p>
							{equipo.fechaMudanza && (
								<p className="text-sm text-blue-700">
									<strong>Fecha:</strong> {equipo.fechaMudanza}
								</p>
							)}
							{equipo.observaciones && (
								<p className="text-sm text-blue-700 mt-2">
									<strong>Observaciones:</strong> {equipo.observaciones}
								</p>
							)}
						</div>

						<div className="flex gap-2">
							<Button
								onClick={confirmarMudanza}
								className="flex-1 bg-green-700 hover:bg-green-800"
							>
								Confirmar Mudanza Completada
							</Button>
							<Button
								variant="outline"
								onClick={() => setIsOpen(false)}
								className="flex-1"
							>
								Cerrar
							</Button>
						</div>
					</div>
				) : (
					<form onSubmit={handleSubmit} className="space-y-4">
						<div>
							<Label htmlFor="ubicacionDestino">Ubicación de Destino</Label>
							<Select
								value={ubicacionDestino}
								onValueChange={setUbicacionDestino}
								required
							>
								<SelectTrigger>
									<SelectValue placeholder="Seleccionar destino" />
								</SelectTrigger>
								<SelectContent>
									<SelectItem value={NONE_SELECTED_VALUE}>
										Seleccionar destino
									</SelectItem>
									{Object.values(ubicaciones)
										.filter((ub) => ub.id !== equipo.ubicacionFisicaId)
										.map((ubicacion) => (
											<SelectItem key={ubicacion.id} value={ubicacion.id}>
												{ubicacion.nombre} ({ubicacion.codigo})
											</SelectItem>
										))}
								</SelectContent>
							</Select>
						</div>

						<div>
							<Label htmlFor="fechaMudanza">Fecha Programada</Label>
							<Input
								type="date"
								id="fechaMudanza"
								value={fechaMudanza}
								onChange={(e) => setFechaMudanza(e.target.value)}
							/>
						</div>

						<div>
							<Label htmlFor="observaciones">Observaciones</Label>
							<Textarea
								id="observaciones"
								value={observaciones}
								onChange={(e) => setObservaciones(e.target.value)}
								placeholder="Motivo de la mudanza, instrucciones especiales, etc."
								rows={3}
							/>
						</div>

						<div className="flex justify-end gap-2 pt-4">
							<Button
								type="button"
								variant="outline"
								onClick={() => setIsOpen(false)}
							>
								Cancelar
							</Button>
							<Button type="submit" className="bg-blue-700 hover:bg-blue-800">
								Programar Mudanza
							</Button>
						</div>
					</form>
				)}
			</DialogContent>
		</Dialog>
	);
}

// Componente para mostrar detalles de equipo
function EquipoDetails({
	equipo,
	ubicaciones,
	marcas,
	equipos,
	setEquipos,
	getFullPath,
	getUbicacionNombre
}: {
	equipo: Equipo;
	ubicaciones: Record<string, UbicacionTecnica>;
	marcas: Record<string, Marca>;
	equipos: Record<string, Equipo>;
	setEquipos: (equipos: Record<string, Equipo>) => void;
	getFullPath: (id: string) => string;
	getUbicacionNombre: (ubicacionId: string) => string;
}) {
	const marca = marcas[equipo.marcaId];
	const ubicacionFisica = equipo.ubicacionFisicaId
		? ubicaciones[equipo.ubicacionFisicaId]
		: null;

	return (
		<Card>
			<CardHeader>
				<div className="flex items-center gap-3">
					<Wrench className="h-8 w-8 text-green-700" />
					<div className="flex-1">
						<CardTitle className="text-xl text-green-800">
							{equipo.nombre}
						</CardTitle>
						<p className="text-sm text-gray-600 mt-1">
							{marca?.nombre} • {equipo.serial}
						</p>
						<div className="flex items-center gap-2 mt-1">
							<Badge className={`text-xs ${estadoEquipoColors[equipo.estado]}`}>
								{equipo.estado.replace(/_/g, ' ')}
							</Badge>
							{equipo.ubicacionFisicaId && (
								<Badge variant="outline" className="text-xs">
									📍 {getUbicacionNombre(equipo.ubicacionFisicaId)}
								</Badge>
							)}
						</div>
					</div>
					<div className="flex gap-2">
						<EditEquipmentDialog
							equipo={equipo}
							equipos={equipos}
							setEquipos={setEquipos}
							ubicaciones={ubicaciones}
							marcas={marcas}
						/>
					</div>
				</div>
			</CardHeader>

			<CardContent className="space-y-6">
				<div className="grid grid-cols-1 md:grid-cols-2 gap-4">
					<div>
						<Label className="text-sm font-medium text-gray-700">
							Código del Equipo
						</Label>
						<p className="text-sm mt-1 font-mono bg-gray-50 p-2 rounded">
							{equipo.codigo}
						</p>
					</div>
					<div>
						<Label className="text-sm font-medium text-gray-700">Marca</Label>
						<p className="text-sm mt-1">{marca?.nombre || 'Sin marca'}</p>
					</div>
				</div>

				<div>
					<Label className="text-sm font-medium text-gray-700">
						Descripción
					</Label>
					<p className="text-sm mt-1">
						{equipo.descripcion || 'Sin descripción'}
					</p>
				</div>

				{ubicacionFisica && (
					<div>
						<Label className="text-sm font-medium text-gray-700">
							Ubicación Física
						</Label>
						<p className="text-sm mt-1">
							{ubicacionFisica.nombre} ({ubicacionFisica.codigo})
						</p>
					</div>
				)}

				{equipo.ubicacionesOperativas.length > 0 && (
					<div>
						<Label className="text-sm font-medium text-gray-700">
							Ubicaciones Operativas
						</Label>
						<div className="space-y-2">
							{equipo.ubicacionesOperativas.map((ubicacionId) => {
								const ubicacion = ubicaciones[ubicacionId];
								return (
									ubicacion && (
										<div
											key={ubicacionId}
											className="flex items-center gap-2 p-2 bg-gray-50 rounded"
										>
											<MapPin className="h-4 w-4 text-green-600" />
											<span className="text-sm flex-1">{ubicacion.nombre}</span>
											<Badge variant="outline" className="text-xs">
												{ubicacion.codigo}
											</Badge>
										</div>
									)
								);
							})}
						</div>
					</div>
				)}

				<Separator />

				<div className="flex justify-between">
					<AssignLocationDialog
						equipo={equipo}
						equipos={equipos}
						setEquipos={setEquipos}
						ubicaciones={ubicaciones}
					/>
					<ScheduleMoveDialog
						equipo={equipo}
						equipos={equipos}
						setEquipos={setEquipos}
						ubicaciones={ubicaciones}
					/>
				</div>
			</CardContent>
		</Card>
	);
}
