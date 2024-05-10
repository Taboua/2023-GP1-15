import { useState } from 'react';
import { Button, Dialog, DialogHeader, DialogBody, DialogFooter,} from "@material-tailwind/react";
import Select from 'react-select';
import makeAnimated from 'react-select/animated';

export default function GarbageBinForm({ open, handler, AddMethod }) {
    const animatedComponents = makeAnimated();
  
    const options = [
      { value: 'حاوية كبيرة', label: 'حاوية كبيرة' },
      { value: 'حاوية صغيرة', label: 'حاوية صغيرة' },
    ];
  
    // Form state
    const [formData, setFormData] = useState({
      size: '',
    });
  
     // Validation state
    const [showValidationMessage, setShowValidationMessage] = useState(false);
  
    // Handle selecting an option in the dropdown
    const handleChange = (selectedOption) => {
      if (selectedOption) {
        const selectedValue = selectedOption.value;
        setFormData({
          ...formData,
          size: selectedValue,
        });
        setShowValidationMessage(false); // Hide the validation message when a selection is made
      } else {
        // Reset the size field
        setFormData({
          ...formData,
          size: '', 
        });
        setShowValidationMessage(true); // Show the validation message when no selection is made
      }
    };
  

    // Handle form submission
    const handleSubmit = (e) => {
      e.preventDefault();
  
      // Check if a size is selected
      if (formData.size) {
        AddMethod(formData);

        // Reset the size field
        setFormData({
          size: '', 
        });
        setShowValidationMessage(false); // Hide the validation message after successful submission
      } else {
        setShowValidationMessage(true); // Show the validation message if no size is selected
      }
    };


    function validate(){
        if(!formData.size){
        setShowValidationMessage(true);
        }else{
            handler();
        }
    }
  
    return (
      <Dialog open={open} handler={handler}>
        <form onSubmit={handleSubmit}>
          <DialogHeader className="flex justify-center font-baloo text-right">
            أضف حاوية نفايات جديدة
          </DialogHeader>
  
          <DialogBody divider className="font-baloo text-right">
            <div className="grid gap-6">
              
              <Select
               placeholder=" أختر نوع الحاوية ..."
                closeMenuOnSelect={false}
                components={animatedComponents}
                options={options}
                value={options.find((option) => option.value === formData.size)}
                onChange={handleChange}
                required
              />
  
              {showValidationMessage && (
                <div>
                  <p className="text-red-500 font-bold">
                    يرجى اختيار حجم الحاوية
                  </p>
                </div>
              )}
            </div>
          </DialogBody>
  
          <DialogFooter className="flex gap-3 justify-center font-baloo text-right">
          <Button
              type="submit"
              variant="gradient"
              style={{ background: '#97B980', color: '#ffffff' }}
              onClick={validate}
            >
              <span>إضافة</span>
            </Button>
            <Button variant="outlined" onClick={handler}>
              <span>إلغاء</span>
            </Button>
          
          </DialogFooter>
        </form>
      </Dialog>
    );
  }
  