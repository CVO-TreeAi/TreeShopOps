// Reusable Input Components

import React from 'react';

// Base Input Component
export const Input = ({ 
  label, 
  error, 
  helpText,
  required = false,
  className = '',
  ...props 
}) => {
  const baseClasses = 'w-full bg-secondary border border-gray-600 rounded-lg px-4 py-2.5 text-text-primary placeholder-text-secondary focus:outline-none focus:ring-2 focus:ring-accent focus:border-transparent smooth-transition';
  const errorClasses = error ? 'border-error focus:ring-error' : '';
  
  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-text-primary">
          {label}
          {required && <span className="text-error ml-1">*</span>}
        </label>
      )}
      <input
        className={`${baseClasses} ${errorClasses} ${className}`}
        {...props}
      />
      {helpText && (
        <p className="text-xs text-text-secondary">{helpText}</p>
      )}
      {error && (
        <p className="text-sm text-error">{error}</p>
      )}
    </div>
  );
};

// Currency Input Component
export const CurrencyInput = ({ 
  label, 
  value, 
  onChange, 
  error,
  helpText,
  required = false,
  ...props 
}) => {
  const handleChange = (e) => {
    // Remove non-numeric characters except decimal point
    const cleaned = e.target.value.replace(/[^0-9.]/g, '');
    onChange(cleaned);
  };

  const displayValue = value ? `$${Number(value).toLocaleString()}` : '';

  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-text-primary">
          {label}
          {required && <span className="text-error ml-1">*</span>}
        </label>
      )}
      <div className="relative">
        <span className="absolute left-3 top-3 text-text-secondary">$</span>
        <input
          type="text"
          value={value || ''}
          onChange={handleChange}
          className={`w-full bg-secondary border border-gray-600 rounded-lg pl-8 pr-4 py-2.5 text-text-primary placeholder-text-secondary focus:outline-none focus:ring-2 focus:ring-accent focus:border-transparent smooth-transition ${error ? 'border-error focus:ring-error' : ''}`}
          placeholder="0"
          {...props}
        />
      </div>
      {helpText && (
        <p className="text-xs text-text-secondary">{helpText}</p>
      )}
      {error && (
        <p className="text-sm text-error">{error}</p>
      )}
    </div>
  );
};

// Select Component
export const Select = ({ 
  label, 
  options = [], 
  value, 
  onChange, 
  error,
  required = false,
  placeholder = "Select an option...",
  ...props 
}) => {
  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-text-primary">
          {label}
          {required && <span className="text-error ml-1">*</span>}
        </label>
      )}
      <select
        value={value || ''}
        onChange={(e) => onChange(e.target.value)}
        className={`w-full bg-secondary border border-gray-600 rounded-lg px-4 py-2.5 text-text-primary focus:outline-none focus:ring-2 focus:ring-accent focus:border-transparent smooth-transition ${error ? 'border-error focus:ring-error' : ''}`}
        {...props}
      >
        <option value="" disabled>{placeholder}</option>
        {options.map((option, index) => (
          <option key={index} value={option}>
            {option}
          </option>
        ))}
      </select>
      {error && (
        <p className="text-sm text-error">{error}</p>
      )}
    </div>
  );
};

// Slider Component  
export const Slider = ({ 
  label, 
  value, 
  onChange, 
  min = 0, 
  max = 100, 
  step = 1,
  showValue = true,
  unit = '',
  ...props 
}) => {
  return (
    <div className="space-y-2">
      {label && (
        <div className="flex justify-between items-center">
          <label className="block text-sm font-medium text-text-primary">
            {label}
          </label>
          {showValue && (
            <span className="text-sm text-accent font-medium">
              {value}{unit}
            </span>
          )}
        </div>
      )}
      <div className="relative">
        <input
          type="range"
          min={min}
          max={max}
          step={step}
          value={value || min}
          onChange={(e) => onChange(Number(e.target.value))}
          className="w-full h-2 bg-gray-600 rounded-lg appearance-none cursor-pointer slider"
          {...props}
        />
        <style jsx>{`
          .slider::-webkit-slider-thumb {
            appearance: none;
            height: 20px;
            width: 20px;
            background: #22c55e;
            border-radius: 50%;
            cursor: pointer;
          }
          
          .slider::-moz-range-thumb {
            height: 20px;
            width: 20px;
            background: #22c55e;
            border-radius: 50%;
            cursor: pointer;
            border: none;
          }
        `}</style>
      </div>
      <div className="flex justify-between text-xs text-text-secondary">
        <span>{min}{unit}</span>
        <span>{max}{unit}</span>
      </div>
    </div>
  );
};