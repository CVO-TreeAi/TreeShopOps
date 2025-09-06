// Multi-step Add Equipment Form

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEquipment } from '../../contexts/EquipmentContext';
import { useFormDraft } from '../../hooks/useLocalStorage';
import { validateEquipmentForm } from '../../utils/validation';
import Layout from '../shared/Layout';
import Button from '../shared/Button';

// Import form steps
import StepOne_Identity from './StepOne_Identity';
import StepTwo_Usage from './StepTwo_Usage';
import StepThree_Purchase from './StepThree_Purchase';
import StepFour_Fuel from './StepFour_Fuel';
import StepFive_Maintenance from './StepFive_Maintenance';
import StepSix_Insurance from './StepSix_Insurance';
import CalculationPreview from './CalculationPreview';

const FORM_STEPS = [
  { component: StepOne_Identity, title: 'Identity', key: 'identity' },
  { component: StepTwo_Usage, title: 'Usage', key: 'usage' },
  { component: StepThree_Purchase, title: 'Purchase', key: 'purchase' },
  { component: StepFour_Fuel, title: 'Fuel', key: 'fuel' },
  { component: StepFive_Maintenance, title: 'Maintenance', key: 'maintenance' },
  { component: StepSix_Insurance, title: 'Insurance', key: 'insurance' }
];

const AddEquipmentForm = () => {
  const navigate = useNavigate();
  const { addEquipment } = useEquipment();
  const [currentStep, setCurrentStep] = useState(0);
  const [errors, setErrors] = useState({});
  const [saving, setSaving] = useState(false);
  
  // Form draft management
  const { draft, updateDraft, clearDraft } = useFormDraft('add-equipment', {
    identity: {},
    usage: { daysPerYear: 200, hoursPerDay: 6 },
    financial: { yearsOfService: 7 }
  });

  const [formData, setFormData] = useState(draft);

  // Auto-save draft
  useEffect(() => {
    updateDraft(formData);
  }, [formData, updateDraft]);

  const updateFormData = (updates) => {
    setFormData(prev => ({
      ...prev,
      ...updates
    }));
    // Clear errors for updated fields
    const updatedFields = Object.keys(updates);
    setErrors(prev => {
      const newErrors = { ...prev };
      updatedFields.forEach(field => {
        delete newErrors[field];
      });
      return newErrors;
    });
  };

  const handleNext = () => {
    // Validate current step
    const validation = validateEquipmentForm(formData);
    
    if (!validation.isValid) {
      setErrors(validation.errors);
      return;
    }

    if (currentStep < FORM_STEPS.length - 1) {
      setCurrentStep(prev => prev + 1);
      setErrors({});
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(prev => prev - 1);
      setErrors({});
    }
  };

  const handleSubmit = async () => {
    // Final validation
    const validation = validateEquipmentForm(formData);
    
    if (!validation.isValid) {
      setErrors(validation.errors);
      return;
    }

    setSaving(true);
    
    try {
      const newEquipment = addEquipment(formData);
      if (newEquipment) {
        clearDraft();
        navigate(`/equipment/${newEquipment.id}`, { 
          state: { justAdded: true }
        });
      } else {
        throw new Error('Failed to save equipment');
      }
    } catch (error) {
      console.error('Error saving equipment:', error);
      setErrors({ submit: 'Failed to save equipment. Please try again.' });
    } finally {
      setSaving(false);
    }
  };

  const CurrentStepComponent = FORM_STEPS[currentStep].component;
  const isLastStep = currentStep === FORM_STEPS.length - 1;
  const progress = ((currentStep + 1) / FORM_STEPS.length) * 100;

  return (
    <Layout 
      title="Add Equipment" 
      subtitle={`Step ${currentStep + 1} of ${FORM_STEPS.length}: ${FORM_STEPS[currentStep].title}`}
      showBackButton 
      onBack={() => navigate('/')}
    >
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-2">
            <span className="text-sm font-medium text-text-secondary">
              Step {currentStep + 1} of {FORM_STEPS.length}
            </span>
            <span className="text-sm font-medium text-accent">
              {Math.round(progress)}% Complete
            </span>
          </div>
          <div className="w-full bg-gray-700 rounded-full h-2">
            <div 
              className="bg-accent h-2 rounded-full smooth-transition" 
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Step Navigation */}
        <div className="flex justify-center mb-8">
          <div className="flex items-center space-x-4">
            {FORM_STEPS.map((step, index) => (
              <React.Fragment key={step.key}>
                <button
                  onClick={() => setCurrentStep(index)}
                  disabled={index > currentStep}
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium smooth-transition ${
                    index === currentStep
                      ? 'bg-accent text-white'
                      : index < currentStep
                      ? 'bg-accent bg-opacity-20 text-accent border border-accent'
                      : 'bg-gray-700 text-text-secondary'
                  } ${index <= currentStep ? 'cursor-pointer' : 'cursor-not-allowed'}`}
                >
                  {index + 1}
                </button>
                {index < FORM_STEPS.length - 1 && (
                  <div className={`w-8 h-0.5 ${index < currentStep ? 'bg-accent' : 'bg-gray-700'}`} />
                )}
              </React.Fragment>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Form Content */}
          <div className="lg:col-span-2">
            <CurrentStepComponent
              formData={formData}
              updateFormData={updateFormData}
              errors={errors}
              onNext={handleNext}
            />

            {/* Form Navigation */}
            <div className="flex justify-between items-center mt-8 pt-6 border-t border-gray-700">
              <Button
                variant="outline"
                onClick={handlePrevious}
                disabled={currentStep === 0}
              >
                Previous
              </Button>

              <div className="flex space-x-3">
                <Button
                  variant="ghost"
                  onClick={() => navigate('/')}
                >
                  Save as Draft
                </Button>
                
                {isLastStep ? (
                  <Button
                    variant="primary"
                    onClick={handleSubmit}
                    loading={saving}
                    disabled={Object.keys(errors).length > 0}
                  >
                    Add Equipment
                  </Button>
                ) : (
                  <Button
                    variant="primary"
                    onClick={handleNext}
                  >
                    Next Step
                  </Button>
                )}
              </div>
            </div>

            {/* Error Display */}
            {errors.submit && (
              <div className="mt-4 p-4 bg-error bg-opacity-20 border border-error rounded-lg">
                <p className="text-error">{errors.submit}</p>
              </div>
            )}
          </div>

          {/* Calculation Preview Sidebar */}
          <div className="lg:col-span-1">
            <div className="sticky top-24 space-y-6">
              <CalculationPreview 
                formData={formData} 
                showDetailed={currentStep >= 2}
              />
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default AddEquipmentForm;