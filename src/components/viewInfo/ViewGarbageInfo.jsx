import {
    Drawer,
    Button,
    Typography,
    IconButton,
    List,
    ListItem,
    ListItemPrefix,
  } from "@material-tailwind/react";
   
  import {
    TrashIcon,
} from "@heroicons/react/24/solid";
 
import
{MdOutlineDateRange}from 'react-icons/md';

import
{HiOutlineHashtag}from 'react-icons/hi';
import Confirm from "../messages/Confirm"
import { useState } from "react";

export default function ViewGarbageInfo({open, onClose , DeleteMethod, bin , binId}){

const [deleteConfirmation , setDeleteConfirmation] = useState(false);

const handleDeleteConfirmation = () => (setDeleteConfirmation(!deleteConfirmation));


// Convert Firestore Timestamp to JavaScript Date
const formattedDate = bin.date && bin.date.toDate().toLocaleString();


return(
    <>
    <Drawer
        placement="right"
        open={open}
        onClose={onClose}
        className="p-4 font-baloo"
      >
        <div className="mb-6 flex items-center justify-between">
          <Typography variant="h5" color="blue-gray">
            <span>معلومات الحاوية</span>
          </Typography>
          <IconButton
            variant="text"
            color="blue-gray"
            onClick={onClose}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              strokeWidth={2}
              stroke="currentColor"
              className="h-5 w-5"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </IconButton>
          </div>
          <List>
          <ListItem ripple={false}>
  <ListItemPrefix>
    <HiOutlineHashtag className="h-5 w-5 ml-2" />
  </ListItemPrefix>
  <div>
    <span className="font-medium">رمز الحاوية:</span>
    <span className="block">{binId}</span> {/* display here the serial number instead of the bin id */}
  </div>
</ListItem>

<ListItem ripple={false}>
  <ListItemPrefix>
    <MdOutlineDateRange  className="h-5 w-5 ml-2" /> 
  </ListItemPrefix>
  <div>
    <span className="font-medium"> تاريخ إضافة الحاوية: </span>
    <span className="block"> {formattedDate}</span> {/* Use block to create a line break */}
  </div>
</ListItem>

<ListItem ripple={false}>
  <ListItemPrefix>
    <MdOutlineDateRange  className="h-5 w-5 ml-2" /> 
  </ListItemPrefix>
  <div>
    <span className="font-medium"> تاريخ إضافة الحاوية: </span>
    <span className="block"> </span> {/* display here the maintainanceDate and enable editing the maintainanceDate*/}
  </div>
</ListItem>


<ListItem ripple={false}>
  <ListItemPrefix>
    <TrashIcon className="h-5 w-5 ml-2" />
  </ListItemPrefix>
  <div>
    <span className="font-medium">  نوع الحاوية: </span>
    <span className="block"> {bin.size}</span> {/* Use block to create a line break */}
  </div>
</ListItem>


 </List>
          
          <Button size="md" fullWidth={true} variant="gradient"  style={{background:"#FE5500", color:'#ffffff'}}   onClick={handleDeleteConfirmation}> <span>حذف الحاوية </span> </Button>
     
      </Drawer>

      <Confirm  open={deleteConfirmation} handler={handleDeleteConfirmation} method={DeleteMethod}  message="   هل انت متأكد من حذف حاوية النفاية بالموقع المحدد؟"/>
 </>
);
}