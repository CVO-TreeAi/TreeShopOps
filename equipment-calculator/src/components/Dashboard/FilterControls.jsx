// Filter and Search Controls

import React from 'react';
import { useEquipment } from '../../contexts/EquipmentContext';
import { EQUIPMENT_CATEGORIES } from '../../utils/constants';
import { Input, Select } from '../shared/Input';

const FilterControls = () => {
  const { filters, setFilter, setSearch, setSort } = useEquipment();

  const sortOptions = [
    { value: 'name', label: 'Name A-Z' },
    { value: 'name_desc', label: 'Name Z-A' },
    { value: 'cost', label: 'Cost Low-High' },
    { value: 'cost_desc', label: 'Cost High-Low' },
    { value: 'date', label: 'Oldest First' },
    { value: 'date_desc', label: 'Newest First' },
    { value: 'category', label: 'Category A-Z' }
  ];

  const handleSortChange = (sortValue) => {
    const [sortBy, order] = sortValue.includes('_desc') 
      ? [sortValue.replace('_desc', ''), 'desc']
      : [sortValue, 'asc'];
    setSort(sortBy, order);
  };

  const currentSortValue = filters.sortOrder === 'desc' 
    ? `${filters.sortBy}_desc` 
    : filters.sortBy;

  return (
    <div className="bg-secondary border border-gray-700 rounded-lg p-6 mb-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Search */}
        <div>
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg className="h-5 w-5 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <input
              type="text"
              placeholder="Search equipment..."
              value={filters.search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-primary border border-gray-600 rounded-lg pl-10 pr-4 py-2.5 text-text-primary placeholder-text-secondary focus:outline-none focus:ring-2 focus:ring-accent focus:border-transparent smooth-transition"
            />
            {filters.search && (
              <button
                onClick={() => setSearch('')}
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-text-secondary hover:text-text-primary"
              >
                <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            )}
          </div>
        </div>

        {/* Category Filter */}
        <Select
          placeholder="Filter by category"
          options={EQUIPMENT_CATEGORIES}
          value={filters.category}
          onChange={(category) => setFilter({ category })}
        />

        {/* Sort Options */}
        <Select
          placeholder="Sort by..."
          options={sortOptions.map(opt => opt.label)}
          value={sortOptions.find(opt => 
            (opt.value === currentSortValue) || 
            (opt.label === filters.sortBy)
          )?.label || ''}
          onChange={(label) => {
            const option = sortOptions.find(opt => opt.label === label);
            if (option) handleSortChange(option.value);
          }}
        />
      </div>

      {/* Active Filters Display */}
      {(filters.category !== 'All' || filters.search) && (
        <div className="flex items-center space-x-3 mt-4 pt-4 border-t border-gray-700">
          <span className="text-sm text-text-secondary">Active filters:</span>
          
          {filters.category !== 'All' && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent bg-opacity-20 text-accent">
              {filters.category}
              <button
                onClick={() => setFilter({ category: 'All' })}
                className="ml-1.5 text-accent hover:text-green-400"
              >
                ×
              </button>
            </span>
          )}
          
          {filters.search && (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-500 bg-opacity-20 text-blue-400">
              "{filters.search}"
              <button
                onClick={() => setSearch('')}
                className="ml-1.5 text-blue-400 hover:text-blue-300"
              >
                ×
              </button>
            </span>
          )}
          
          <button
            onClick={() => {
              setFilter({ category: 'All' });
              setSearch('');
            }}
            className="text-xs text-text-secondary hover:text-text-primary smooth-transition"
          >
            Clear all
          </button>
        </div>
      )}
    </div>
  );
};

export default FilterControls;