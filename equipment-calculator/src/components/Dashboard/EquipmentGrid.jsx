// Equipment Grid Component

import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useEquipment } from '../../contexts/EquipmentContext';
import { formatCurrency } from '../../utils/calculations';
import Button from '../shared/Button';

const EquipmentCard = ({ equipment, onView, onEdit, onDelete }) => {
  const { identity, calculated, metadata } = equipment;
  
  // Status colors
  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'text-accent';
      case 'maintenance': return 'text-warning';
      case 'retired': return 'text-error';
      default: return 'text-text-secondary';
    }
  };

  const utilizationColor = metadata.utilization >= 70 ? 'text-accent' :
                          metadata.utilization >= 40 ? 'text-warning' : 
                          'text-error';

  return (
    <div className="bg-secondary border border-gray-700 rounded-lg p-6 hover:border-accent smooth-transition group">
      {/* Equipment Header */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-text-primary group-hover:text-accent smooth-transition">
            {identity.equipmentName || 'Unnamed Equipment'}
          </h3>
          <p className="text-text-secondary">
            {identity.year && `${identity.year} `}
            {identity.make && `${identity.make} `}
            {identity.model && identity.model}
          </p>
        </div>
        
        {/* Category Badge */}
        {identity.category && (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent bg-opacity-20 text-accent">
            {identity.category}
          </span>
        )}
      </div>

      {/* Key Metrics */}
      <div className="space-y-3 mb-6">
        <div className="flex justify-between items-center">
          <span className="text-text-secondary">Hourly Cost:</span>
          <span className="text-xl font-bold text-accent">
            {formatCurrency(calculated.hourlyCost)}
          </span>
        </div>
        
        <div className="flex justify-between items-center">
          <span className="text-text-secondary">Recommended Rate:</span>
          <span className="text-lg font-medium text-text-primary">
            {formatCurrency(calculated.recommendedRate)}
          </span>
        </div>

        <div className="flex justify-between items-center">
          <span className="text-text-secondary">Status:</span>
          <span className={`text-sm font-medium ${getStatusColor(metadata.status)}`}>
            {metadata.status?.charAt(0).toUpperCase() + metadata.status?.slice(1) || 'Unknown'}
          </span>
        </div>

        <div className="flex justify-between items-center">
          <span className="text-text-secondary">Utilization:</span>
          <span className={`text-sm font-medium ${utilizationColor}`}>
            {metadata.utilization || 0}%
          </span>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex items-center space-x-2">
        <Button
          variant="outline"
          size="sm"
          onClick={() => onView(equipment.id)}
          className="flex-1"
        >
          View Details
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => onEdit(equipment.id)}
          className="flex-1"
        >
          Edit
        </Button>
        <button
          onClick={() => onDelete(equipment.id)}
          className="touch-friendly w-10 h-10 rounded-lg bg-error bg-opacity-20 text-error hover:bg-opacity-30 smooth-transition flex items-center justify-center"
          aria-label="Delete equipment"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
          </svg>
        </button>
      </div>
    </div>
  );
};

const EmptyState = ({ onAddEquipment }) => (
  <div className="text-center py-16">
    <div className="w-16 h-16 bg-accent bg-opacity-20 rounded-full flex items-center justify-center mx-auto mb-4">
      <svg className="w-8 h-8 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-2-5h6m-6 0V9a2 2 0 012-2h2a2 2 0 012 2v6.5M7 7h3m0 0h3M7 7v3m3-3v3m0 0h3m-3 0v3" />
      </svg>
    </div>
    <h3 className="text-xl font-medium text-text-primary mb-2">No Equipment Found</h3>
    <p className="text-text-secondary mb-6 max-w-md mx-auto">
      Start building your equipment directory by adding your first piece of equipment. 
      Track costs and optimize your fleet performance.
    </p>
    <Button
      variant="primary"
      onClick={onAddEquipment}
      className="mx-auto"
    >
      <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
      </svg>
      Add Your First Equipment
    </Button>
  </div>
);

const EquipmentGrid = () => {
  const navigate = useNavigate();
  const { filteredEquipment, deleteEquipment } = useEquipment();

  const handleView = (equipmentId) => {
    navigate(`/equipment/${equipmentId}`);
  };

  const handleEdit = (equipmentId) => {
    navigate(`/equipment/${equipmentId}/edit`);
  };

  const handleDelete = (equipmentId) => {
    if (window.confirm('Are you sure you want to delete this equipment? This action cannot be undone.')) {
      deleteEquipment(equipmentId);
    }
  };

  const handleAddEquipment = () => {
    navigate('/add');
  };

  if (filteredEquipment.length === 0) {
    return <EmptyState onAddEquipment={handleAddEquipment} />;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {filteredEquipment.map(equipment => (
        <EquipmentCard
          key={equipment.id}
          equipment={equipment}
          onView={handleView}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      ))}
    </div>
  );
};

export default EquipmentGrid;