// Real-time Calculation Preview Component

import React from 'react';
import { calculateEquipmentCosts, formatCurrency } from '../../utils/calculations';
import { generateQualityAlerts } from '../../utils/validation';

const CalculationPreview = ({ formData, showDetailed = false }) => {
  const calculated = calculateEquipmentCosts(formData);
  const alerts = generateQualityAlerts(calculated, formData);

  if (!formData.financial?.purchasePrice || !formData.usage?.daysPerYear) {
    return (
      <div className="bg-secondary border border-gray-700 rounded-lg p-6 text-center">
        <p className="text-text-secondary">Complete the form to see cost calculations</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Primary Metrics */}
      <div className="bg-primary border border-gray-700 rounded-lg p-6">
        <h3 className="text-lg font-medium text-text-primary mb-4">Key Metrics</h3>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
          <div className="text-center">
            <p className="text-3xl font-bold text-accent">
              {formatCurrency(calculated.hourlyCost)}
            </p>
            <p className="text-sm text-text-secondary">Hourly Cost</p>
          </div>
          <div className="text-center">
            <p className="text-3xl font-bold text-text-primary">
              {formatCurrency(calculated.recommendedRate)}
            </p>
            <p className="text-sm text-text-secondary">Recommended Rate</p>
          </div>
          <div className="text-center md:col-span-1 col-span-2">
            <p className="text-3xl font-bold text-warning">
              {calculated.annualHours.toLocaleString()}
            </p>
            <p className="text-sm text-text-secondary">Annual Hours</p>
          </div>
        </div>
      </div>

      {/* Detailed Breakdown */}
      {showDetailed && (
        <div className="bg-secondary border border-gray-700 rounded-lg p-6">
          <h3 className="text-lg font-medium text-text-primary mb-4">Annual Cost Breakdown</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-text-secondary">Depreciation</span>
              <span className="text-text-primary font-medium">
                {formatCurrency(calculated.annualDepreciation)}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-text-secondary">Fuel</span>
              <span className="text-text-primary font-medium">
                {formatCurrency(calculated.annualFuel)}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-text-secondary">Maintenance</span>
              <span className="text-text-primary font-medium">
                {formatCurrency(calculated.annualMaintenance)}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-text-secondary">Insurance</span>
              <span className="text-text-primary font-medium">
                {formatCurrency(formData.financial?.annualInsuranceCost || 0)}
              </span>
            </div>
            <div className="border-t border-gray-700 pt-2">
              <div className="flex justify-between items-center">
                <span className="text-text-primary font-medium">Total Annual Cost</span>
                <span className="text-xl font-bold text-accent">
                  {formatCurrency(calculated.totalAnnualCost)}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Quality Alerts */}
      {alerts.length > 0 && (
        <div className="space-y-3">
          {alerts.map((alert, index) => (
            <div 
              key={index}
              className={`border rounded-lg p-4 ${
                alert.type === 'error' 
                  ? 'border-error bg-red-900 bg-opacity-20'
                  : alert.type === 'warning'
                  ? 'border-warning bg-yellow-900 bg-opacity-20' 
                  : 'border-blue-700 bg-blue-900 bg-opacity-20'
              }`}
            >
              <div className="flex items-start space-x-3">
                <svg 
                  className={`flex-shrink-0 w-5 h-5 mt-0.5 ${
                    alert.type === 'error' 
                      ? 'text-red-400'
                      : alert.type === 'warning'
                      ? 'text-yellow-400'
                      : 'text-blue-400'
                  }`}
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  {alert.type === 'error' ? (
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  ) : alert.type === 'warning' ? (
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
                  ) : (
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  )}
                </svg>
                <p className={`text-sm ${
                  alert.type === 'error' 
                    ? 'text-red-200'
                    : alert.type === 'warning'
                    ? 'text-yellow-200'
                    : 'text-blue-200'
                }`}>
                  {alert.message}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Profitability Summary */}
      {calculated.recommendedRate > 0 && (
        <div className="bg-accent bg-opacity-10 border border-accent rounded-lg p-6">
          <h3 className="text-lg font-medium text-text-primary mb-4">Profitability Analysis</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h4 className="text-sm font-medium text-text-secondary mb-2">Cost Structure</h4>
              <div className="space-y-1 text-sm">
                <div className="flex justify-between">
                  <span>Operating Cost:</span>
                  <span className="text-text-primary">{formatCurrency(calculated.hourlyCost)}/hr</span>
                </div>
                <div className="flex justify-between">
                  <span>30% Markup:</span>
                  <span className="text-accent">+{formatCurrency((calculated.recommendedRate - calculated.hourlyCost))}/hr</span>
                </div>
                <div className="flex justify-between font-medium border-t border-gray-700 pt-1">
                  <span>Billing Rate:</span>
                  <span className="text-accent">{formatCurrency(calculated.recommendedRate)}/hr</span>
                </div>
              </div>
            </div>
            <div>
              <h4 className="text-sm font-medium text-text-secondary mb-2">Annual Revenue Potential</h4>
              <div className="space-y-1 text-sm">
                <div className="flex justify-between">
                  <span>Gross Revenue:</span>
                  <span className="text-text-primary">
                    {formatCurrency(calculated.recommendedRate * calculated.annualHours)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Operating Costs:</span>
                  <span className="text-error">
                    -{formatCurrency(calculated.totalAnnualCost)}
                  </span>
                </div>
                <div className="flex justify-between font-medium border-t border-gray-700 pt-1">
                  <span>Net Profit:</span>
                  <span className="text-accent">
                    {formatCurrency((calculated.recommendedRate * calculated.annualHours) - calculated.totalAnnualCost)}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CalculationPreview;