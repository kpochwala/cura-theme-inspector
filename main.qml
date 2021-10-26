import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0
import "qml-utils/JSONListModel"
import QtGraphicalEffects 1.0

ApplicationWindow {
    id: root

    width: 640
    height: 480
    visible: true
    title: "Cura theme inspector. F5 to reload " + themeSource

    property var colors
    property ListModel model: ListModel {id: jsonModel}
    signal jsonModelChanged;

    property var themeSource: "press ctrl + o to open theme"/*: "file:///D:/theme.json"*/

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: "file:///C:/Program Files/Ultimaker Cura 4.11.0/resources/themes"
        nameFilters: ["Cura json theme file (*.theme) (*.json)"]
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrls)
            root.themeSource = fileDialog.fileUrls
            root.reloadJSON()
        }
        onRejected: {
            console.log("Canceled")
            Qt.quit()
        }
        Component.onCompleted: visible = true
    }

    function reloadJSON() {

        jsonModel.clear()
        var source = root.themeSource
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                var objects = JSON.parse(xhr.responseText)
                root.colors = objects.colors

                for (var color_name in root.colors) {
                    console.log(color_name)
                    console.log(objects.colors[color_name])
                    jsonModel.append({"color_name": color_name, "r": objects.colors[color_name][0], "g": objects.colors[color_name][1], "b": objects.colors[color_name][2], "a": objects.colors[color_name][3]})
                }

                jsonModelChanged()
        }
        xhr.send();
    }

    onJsonModelChanged: {
        listView.model = jsonModel
        listView.modelUpdated()
    }

    ScrollView {
        anchors.fill: parent

        ListView  {
            id: listView
            width: parent.width

            model: root.jsonModel

            delegate: ItemDelegate {

                text: "\"" + model.color_name + "\": " + "[" + model.r + ", " + model.g + ", " + model.b + ", " + model.a + "]"

                TextEdit{
                    id: textEdit
                    visible: false
                }

                onClicked: {
                    textEdit.text = text
                    textEdit.selectAll()
                    textEdit.copy()
                }

                Rectangle {
                    height: parent.height
                    width: 150
                    anchors.right: parent.right
                    color: Qt.rgba(model.r/255, model.g/255, model.b/255, model.a/255)
                }
                width: listView.width

                Component.onCompleted: {
                    util.listProperty(model.color_array)
                }
            }
        }
    }

    Shortcut {
        sequence: StandardKey.Open
        onActivated: {
            fileDialog.open()
        }
    }

    Shortcut {
        sequence: StandardKey.Refresh
        onActivated: {
            root.reloadJSON()
        }
    }

    Item {
    id: util
    function listProperty(item)
    {
        console.log("-------------------------------------")
        for (var p in item)
        console.log(p + ": " + item[p]);
    }
    }

}
