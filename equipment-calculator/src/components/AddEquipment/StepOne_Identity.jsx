// Step 1: Equipment Identity

import React from 'react';
import { Input, Select } from '../shared/Input';
import { EQUIPMENT_CATEGORIES } from '../../utils/constants';

const StepOne_Identity = ({ 
  formData, 
  updateFormData, 
  errors = {},
  onNext 
}) => {
  const handleInputChange = (field, value) => {
    updateFormData({
      identity: {
        ...formData.identity,
        [field]: value
      }
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onNext();
  };

  // Filter out 'All' from categories for form
  const categoryOptions = EQUIPMENT_CATEGORIES.filter(cat => cat !== 'All');

  return (
    <div className="space-y-6">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Equipment Identity</h2>
        <p className="text-text-secondary">Tell us about your equipment</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Equipment Name */}
          <div className="md:col-span-2">
            <Input
              label="Equipment Name"
              placeholder="e.g., CAT 289D - Unit 1"
              value={formData.identity?.equipmentName || ''}
              onChange={(e) => handleInputChange('equipmentName', e.target.value)}
              error={errors.equipmentName}
              required
            />
          </div>

          {/* Year */}
          <Input
            label="Year"
            type="number"
            placeholder="e.g., 2018"
            min="1990"
            max="2030"
            value={formData.identity?.year || ''}
            onChange={(e) => handleInputChange('year', e.target.value)}
            error={errors.year}
            required
          />

          {/* Category */}
          <Select
            label="Category"
            placeholder="Select equipment category"
            options={categoryOptions}
            value={formData.identity?.category || ''}
            onChange={(value) => handleInputChange('category', value)}
            error={errors.category}
            required
          />

          {/* Make */}
          <Input
            label="Make"
            placeholder="e.g., Caterpillar"
            value={formData.identity?.make || ''}
            onChange={(e) => handleInputChange('make', e.target.value)}
            error={errors.make}
            required
          />

          {/* Model */}
          <Input
            label="Model"
            placeholder="e.g., 289D"
            value={formData.identity?.model || ''}
            onChange={(e) => handleInputChange('model', e.target.value)}
            error={errors.model}
            required
          />

          {/* Serial Number */}
          <div className="md:col-span-2">
            <Input
              label="Serial Number"
              placeholder="Optional - for your records"
              value={formData.identity?.serialNumber || ''}
              onChange={(e) => handleInputChange('serialNumber', e.target.value)}
              error={errors.serialNumber}
            />
          </div>
        </div>

        {/* Equipment Preview Card */}
        {(formData.identity?.equipmentName || formData.identity?.make) && (
          <div className="bg-primary border border-gray-700 rounded-lg p-4 mt-8">
            <h3 className="text-sm font-medium text-text-secondary mb-2">Preview</h3>
            <div className="space-y-1">
              <p className="text-text-primary font-medium">
                {formData.identity?.equipmentName || 'Unnamed Equipment'}
              </p>
              <p className="text-text-secondary">
                {formData.identity?.year && `${formData.identity.year} `}
                {formData.identity?.make && `${formData.identity.make} `}
                {formData.identity?.model && formData.identity.model}
              </p>
              {formData.identity?.category && (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent bg-opacity-20 text-accent">
                  {formData.identity.category}
                </span>
              )}
            </div>
          </div>
        )}

        {/* Help Text */}
        <div className="bg-blue-900 bg-opacity-20 border border-blue-700 rounded-lg p-4">
          <div className="flex items-start space-x-3">
            <svg className="flex-shrink-0 w-5 h-5 text-blue-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <h4 className="text-sm font-medium text-blue-400">Equipment Naming Tip</h4>
              <p className="text-sm text-blue-200 mt-1">
                Use descriptive names like "CAT 289D - Unit 1" to easily identify equipment in your fleet. Include unit numbers if you have multiple of the same model.
              </p>
            </div>
          </div>
        </div>
      </form>
    </div>
  );
};

export default StepOne_Identity;