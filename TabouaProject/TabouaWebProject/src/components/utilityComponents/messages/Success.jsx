import {
    Button,
    Dialog,
    DialogHeader,
    DialogBody,
    DialogFooter,
  } from "@material-tailwind/react";

export default function Success({open , handler, message }){

  // to show success message
    return(
<Dialog size = "xs" open={open} handler={handler}  >
                    
                    <DialogHeader className="font-baloo flex justify-center" >تم التنفيذ بنجاح</DialogHeader>
                   
                    <DialogBody divider className="font-baloo text-right">
                    {message} 
                    </DialogBody>

                    <DialogFooter className="flex gap-3 justify-center">
                      <Button
                        variant="gradient"
                        style={{background:"#97B980", color:'#ffffff'}} 
                        onClick={handler}
                        className="mr-1"
                      >
                        <span>استمرار</span>
                      </Button>
                    </DialogFooter>
                  </Dialog>
    )
}
