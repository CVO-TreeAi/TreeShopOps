// Step 6: Insurance Cost

import React from 'react';
import { CurrencyInput } from '../shared/Input';

const StepSix_Insurance = ({ 
  formData, 
  updateFormData, 
  errors = {} 
}) => {
  const financial = formData.financial || {};
  const annualInsuranceCost = Number(financial.annualInsuranceCost) || 0;

  const handleInsuranceUpdate = (value) => {
    updateFormData({
      financial: {
        ...financial,
        annualInsuranceCost: Number(value) || 0
      }
    });
  };

  // Insurance estimates by equipment value
  const purchasePrice = Number(financial.purchasePrice) || 0;
  const lowEstimate = Math.round(purchasePrice * 0.03);  // 3% of value
  const highEstimate = Math.round(purchasePrice * 0.08); // 8% of value
  const avgEstimate = Math.round(purchasePrice * 0.055); // 5.5% of value

  return (
    <div className="space-y-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Insurance Cost</h2>
        <p className="text-text-secondary">Annual insurance and liability costs</p>
      </div>

      <div className="space-y-6">
        {/* Insurance Cost Input */}
        <CurrencyInput
          label="Annual Insurance Cost"
          placeholder="6500"
          value={financial.annualInsuranceCost || ''}
          onChange={handleInsuranceUpdate}
          error={errors.annualInsuranceCost}
          helpText="Include equipment coverage and general liability"
        />

        {/* Insurance Estimates */}
        {purchasePrice > 0 && (
          <div className="bg-secondary border border-gray-700 rounded-lg p-4">
            <h3 className="text-sm font-medium text-text-primary mb-3">
              Typical Insurance Costs for ${purchasePrice.toLocaleString()} Equipment
            </h3>
            <div className="grid grid-cols-3 gap-4 text-center">
              <button
                type="button"
                onClick={() => handleInsuranceUpdate(lowEstimate)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition"
              >
                <p className="text-lg font-bold text-text-primary">${lowEstimate.toLocaleString()}</p>
                <p className="text-xs text-text-secondary">Basic Coverage (3%)</p>
              </button>
              <button
                type="button"
                onClick={() => handleInsuranceUpdate(avgEstimate)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition border-2 border-accent"
              >
                <p className="text-lg font-bold text-accent">${avgEstimate.toLocaleString()}</p>
                <p className="text-xs text-accent">Standard (5.5%)</p>
              </button>
              <button
                type="button"
                onClick={() => handleInsuranceUpdate(highEstimate)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition"
              >
                <p className="text-lg font-bold text-text-primary">${highEstimate.toLocaleString()}</p>
                <p className="text-xs text-text-secondary">Full Coverage (8%)</p>
              </button>
            </div>
          </div>
        )}

        {/* Monthly Cost Breakdown */}
        {annualInsuranceCost > 0 && (
          <div className="bg-accent bg-opacity-10 border border-accent rounded-lg p-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="text-center">
                <p className="text-2xl font-bold text-accent">
                  ${annualInsuranceCost.toLocaleString()}
                </p>
                <p className="text-sm text-text-secondary">Annual Cost</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-text-primary">
                  ${Math.round(annualInsuranceCost / 12).toLocaleString()}
                </p>
                <p className="text-sm text-text-secondary">Monthly Cost</p>
              </div>
            </div>
          </div>
        )}

        {/* Skip Insurance Option */}
        <div className="text-center">
          <button
            type="button"
            onClick={() => handleInsuranceUpdate(0)}
            className="text-text-secondary hover:text-text-primary smooth-transition text-sm"
          >
            Skip insurance (set to $0)
          </button>
        </div>
      </div>

      {/* Insurance Guidelines */}
      <div className="bg-blue-900 bg-opacity-20 border border-blue-700 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <svg className="flex-shrink-0 w-5 h-5 text-blue-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h4 className="text-sm font-medium text-blue-400">Insurance Considerations</h4>
            <ul className="text-sm text-blue-200 mt-1 space-y-1">
              <li>• Include equipment coverage and general liability</li>
              <li>• Higher value equipment needs more coverage</li>
              <li>• Some clients require proof of insurance</li>
              <li>• Shop around annually for better rates</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepSix_Insurance;