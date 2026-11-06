codeunit 50203 "NAV Transit Folder Attachments"
{
    // Standard document attachments (Document Attachment table) for the Transit Folder:
    // several files of any type (PDF, Word, text, pictures...) per folder.
    // Recent versions handle attachments in codeunit "Document Attachment Mgmt":
    // declaring that the Transit Folder table has a "No." primary key (field 1) is
    // enough for the standard to store, filter and open the attachments.

    // The Transit Folder primary key is "No." (field 1)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnAfterTableHasNumberFieldPrimaryKey', '', false, false)]
    local procedure TransitFolderHasNoPrimaryKey(TableNo: Integer; var Result: Boolean; var FieldNo: Integer)
    begin
        if TableNo <> Database::"NAV Transit Folder" then
            exit;
        Result := true;
        FieldNo := 1;
    end;

    // Opening an attachment from the factbox: find the folder it belongs to
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnAfterGetRefTable', '', false, false)]
    local procedure GetFolderOnAfterGetRefTable(var RecRef: RecordRef; DocumentAttachment: Record "Document Attachment")
    var
        TransitFolder: Record "NAV Transit Folder";
    begin
        if DocumentAttachment."Table ID" <> Database::"NAV Transit Folder" then
            exit;
        RecRef.Open(Database::"NAV Transit Folder");
        if TransitFolder.Get(DocumentAttachment."No.") then
            RecRef.GetTable(TransitFolder);
    end;

    // Deleting a folder deletes its attachments
    [EventSubscriber(ObjectType::Table, Database::"NAV Transit Folder", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachmentsOnAfterDeleteFolder(var Rec: Record "NAV Transit Folder"; RunTrigger: Boolean)
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        if Rec.IsTemporary() then
            exit;
        DocumentAttachment.SetRange("Table ID", Database::"NAV Transit Folder");
        DocumentAttachment.SetRange("No.", Rec."No.");
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll();
    end;
}
