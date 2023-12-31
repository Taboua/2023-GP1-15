

import { Alert, Button, Typography } from "@material-tailwind/react";
 
// alert icon 
function Icon() {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="currentColor"
      className="h-6 w-6"
    >
      <path
        fillRule="evenodd"
        d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm8.706-1.442c1.146-.573 2.437.463 2.126 1.706l-.709 2.836.042-.02a.75.75 0 01.67 1.34l-.04.022c-1.147.573-2.438-.463-2.127-1.706l.71-2.836-.042.02a.75.75 0 11-.671-1.34l.041-.022zM12 9a.75.75 0 100-1.5.75.75 0 000 1.5z"
        clipRule="evenodd"
      />
    </svg>
  );
}
 
export default function AlertMessage({open, handler, message}) {
  
 // show alert message
  return (
    <>
      <Alert
        variant="gradient"
        open={open}
        icon={<Icon/>}
        style={{background:"#FE9B00", color:'#ffffff'}}
        action={
          <Button
            variant="text"
            color="white"
            size="sm"
            className="!absolute top-3 left-0 "
            onClick={handler}
          >
         <span> إغلاق</span> 
          </Button>
        }
      >
        <Typography className="font-medium">
      <span className="ml-96 pl-2"> {message}</span> 
      </Typography>
      <ul className="mt-2 ml-2 list-inside list-disc">
          <li> لتغيير الموقع قم بالضغط  على الموقع المراد على الخريطة</li>
          <li>اضغط اغلاق للخروج من الوضع</li>
        </ul>
      </Alert>
    </>
  );
}