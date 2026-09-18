import 'package:flutter/material.dart';
import '../models/network_device.dart';
import '../utils/device_presentation.dart';

typedef DeviceEdits = ({String name, String notes, DeviceClassification classification});

class DeviceEditDialog extends StatefulWidget {
  const DeviceEditDialog({super.key,required this.device});
  final NetworkDevice device;
  @override
  State<DeviceEditDialog> createState() => _DeviceEditDialogState();
}
class _DeviceEditDialogState extends State<DeviceEditDialog> {
  late final name = TextEditingController(text:widget.device.customName);
  late final notes = TextEditingController(text:widget.device.notes);
  late var classification = widget.device.classification;
  @override
  void dispose() { name.dispose(); notes.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(title:const Text('Edit device'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,maxLength:120,decoration:const InputDecoration(labelText:'Custom name',hintText:'Leave empty to use discovered name')),
      DropdownButtonFormField<DeviceClassification>(initialValue:classification,
        decoration:const InputDecoration(labelText:'Classification'),
        items:DeviceClassification.values.map((v) => DropdownMenuItem(value:v,child:Text(v.label))).toList(),
        onChanged:(v) { if(v != null) setState(() => classification=v); }),
      TextField(controller:notes,minLines:3,maxLines:6,maxLength:4000,decoration:const InputDecoration(labelText:'Notes')),
    ])),
    actions:[TextButton(onPressed:() => Navigator.pop(context),child:const Text('Cancel')),
      FilledButton(onPressed:() => Navigator.pop<DeviceEdits>(context,
        (name:name.text,notes:notes.text,classification:classification)),child:const Text('Save'))],
  );
}
