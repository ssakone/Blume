import QtQuick
import QtQml

import "pages"
import "pages/Plant"
import "pages/Insect"
import "pages/Auth"
import "pages/Garden"
import "pages/Device"
import "pages/Social"

Item {
    property var deviceList: Component {
        DeviceList {}
    }
    property var descriptionPage: Component {
        DescriptionScreen {}
    }
    property var deviceScannerPage: Component {
        DeviceScanPage {}
    }
    property var plantIdentifierPage: Component {
        PlantIdentifier {}
    }
    property var posometrePage: Component {
        Posometre {}
    }
    property var askToExperts: Component {
        AskHelp {}
    }

    property var deseasePage: Component {
        PlantDesease {}
    }
    property var deseaseEncyclopedie: Component {
        PlantDeseaseEncylopedie {}
    }
    property var deseaseDetailsPage: Component {
        PlantDeseaseDetails {}
    }
    property var plantBrowserPage: Component {
        PlantBrowser {}
    }
    property var plantCategoriesBrowserPage: Component {
        PlantBrowseCategory {}
    }
    property var plantDetailPage: Component {
        PlantScreenDetails {}
    }
    property var plantPage: Component {
        Plant {}
    }
    property var plantFlowercheckerPage: Component {
        PlantFlowerchecker {}
    }
    property var plantSearchPage: Component {
        PlantSearch {}
    }
    property var plantShortDescriptionsPage: Component {
        PlantShortDescriptions {}
    }
    property var plantFrequenciesPage: Component {
        PlantFrequencies {}
    }
    property var plantIdentifierResultsPage: Component {
        PlantIdentifierResultsScreen {}
    }
    property var diseaseIdentifierResultsPage: Component {
        DiseasIdentifierResultsScreen {}
    }
    property var insectIdentifier: Component {
        InsectIdentifier {}
    }
    property var insectIdentifierResultsPage: Component {
        InsectIdentifierResultsList {}
    }
    property var insectDetailPage: Component {
        InsectDetailsScreen {}
    }
    property var loginPage: Component {
        Login {}
    }
    property var registerPage: Component {
        Register {}
    }
    property var signInPage: Component {
        SignIn {}
    }
    property var gardenScreen: Component {
        GardenScreen {}
    }
    property var gardenPlantsList: Component {
        GardenPlantsList {}
    }
    property var gardenSpacesList: Component {
        GardenSpacesList {}
    }
    property var gardenSpaceDetails: Component {
        GardenSpaceDetails {}
    }
    property var gardenAlarmsCalendar: Component {
        AlarmsCalendar {}
    }
    property var gardenEditSpace: Component {
        GardenEditSpace {}
    }
    property var blogPage: Component {
        BlogScreen {}
    }

    property var feedPage: Component {
        Feed {}
    }

    property var social: Component {
        App {}
    }

    Connections {
        target: $Signaler
        function onShowPlant(plant) {
            page_view.push(plantPage, {
                               "plant": plant
                           })
        }
    }
}
