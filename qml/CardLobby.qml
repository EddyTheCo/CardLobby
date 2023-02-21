import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import MyDesigns
import nft_model
import userSettings
import account
import bout_monitor
import bout_publisher
import players_model

MyFrame
{
    id:root_
    required property NFT_model umodel;
    required property UserSetts usett;
    description: qsTr("Game Lobby")


    MyPayPopUp
    {
        id:paypopup
        addr_:""
        descr_:""
        visible:false
        closePolicy: Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
    }
    BoutMonitor{
        id:playersmonitor_
        connection: Node_Conection
        tag:"iwantoplaycards"
        onReady:
        {

            console.log("Ready");
            playersmodel.add_monitor(playersmonitor_);
            playersmonitor_.restMonitor();
        }
    }
    BoutMonitor{
        id:fundsmonitor
        connection: Node_Conection
        onReady:
        {
            fundsmonitor.addr=Account.addr([0,0,0]);
        }
        onGotNewBout:
        {
            paypopup.visible=false;
        }

    }
    BoutPublisher
    {
        id:publisher
        connection: Node_Conection
        account: Account
        onNotenoughFunds: function (amount) {
            paypopup.addr_=Account.addr([0,0,0]);
            paypopup.descr_=qsTr("Transfer at least "+ amount + " to \n" +paypopup.addr_);
            paypopup.visible=true;
            fundsmonitor.eventMonitor();
        }
    }
    Players_model
    {
        id:playersmodel
    }

    RowLayout
    {
        id:rowllay
        anchors.fill: parent
        spacing: 10
        ColumnLayout
        {
            id:left_

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 100
            Layout.alignment: Qt.AlignLeft

            spacing:20
            OpponentDetail
            {
                umodel:root_.umodel
                usett:root_.usett
                opponent:null
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 360
                Layout.minimumHeight: 300
                Layout.alignment: Qt.AlignTop
            }

            MyButton
            {
                id:scards
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 250
                Layout.maximumHeight: 100
                Layout.alignment: Qt.AlignHCenter
                text:qsTr("I want to play")
                onClicked:{
                    console.log()
                    var objson={
                        "cards": root_.umodel.getCardIds(),
                        "username":root_.usett.username
                    };
                    if(root_.usett.nftbox)
                    {
                        objson.profpic=root_.usett.nftbox.nftid;
                    }
                    publisher.publish(objson,Account.addr([0,0,0]),"iwantoplaycards",[0,0,0],-1000,true);
                }
            }

        }


        ListView {
            id:playersview
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.preferredWidth: 360
            Layout.maximumWidth: 360
            orientation:ListView.Vertical
            Layout.alignment: Qt.AlignRight

            flickableDirection:Flickable.VerticalFlick

            model: playersmodel
            delegate: PlayersDelegate {
                width:playersview.width
                height:playersview.height/4.0
            }
        }


    }

}
