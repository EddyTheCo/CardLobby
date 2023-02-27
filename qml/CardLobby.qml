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
import nodeConection

MyFrame
{
    id:root_
    required property NFT_model umodel;
    required property UserSetts usett;
    description: qsTr("Game Lobby")
    Connections {
        target: Account

        function onSeedChanged() {
            fundsmonitor.restart();
            fundsmonitor.addr=Account.addr([0, 0, 0]);
            if(fundsmonitor.init)
            {
                fundsmonitor.addressMonitor();
            }
            duelmonitor.restart();
            duelmonitor.addr=Account.addr([0, 0, 0]);
        }
    }

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
        tag:"iwantoplaycards"
        rpeat:10000
        createdAfter: new Date()
        Component.onCompleted:
        {
            playersmonitor_.restMonitor();
        }
    }
    BoutMonitor{
        id:fundsmonitor
        property bool init:false
        addr:Account.addr([0,0,0]);
        Component.onCompleted:
        {
            fundsmonitor.addressMonitor();
            fundsmonitor.init=true;
        }
        onGotNewBout:
        {
            paypopup.visible=false;
        }
    }
    BoutMonitor{
        id:duelmonitor
        addr:Account.addr([0,0,0]);
        tag:"letsduel"
        rpeat:10000
    }
    BoutPublisher
    {
        id:publisher
        onNotenoughFunds: function (amount) {
            paypopup.addr_=Account.addr_bech32([0,0,0]);
            paypopup.descr_=qsTr("Transfer at least "+ amount + " to \n" +paypopup.addr_);
            paypopup.visible=true;

        }
    }
    Players_model
    {
        id:playersmodel
        onSelected: (box) => oponentdetail.opponent=box;
        Component.onCompleted:
        {
            playersmodel.add_monitor(playersmonitor_,Account.addr([0,0,0]));
            playersmodel.add_monitor(duelmonitor,Account.addr([0,0,0]));
            playersmonitor_.restMonitor();
        }


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
                id:oponentdetail
                umodel:root_.umodel
                usett:root_.usett
                opponent:null
                playersmodel:playersmodel
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

                    var objson={
                        "cards": root_.umodel.gameCards.getCardIds(),
                        "username":root_.usett.username
                    };
                    if(root_.usett.nftbox)
                    {
                        objson.profpic=root_.usett.nftbox.nftid;
                    }

                    publisher.publish(objson,Account.addr([0,0,0]),"iwantoplaycards",[0,0,0],-1000);
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
