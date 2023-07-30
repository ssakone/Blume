import QtQuick
import QtQml

import "pages"
import "pages/Plant"
import "pages/Insect"
import "pages/Auth"
import "pages/Garden"

Item {
    property var deviceList: Component {
        DeviceList {}
    }
    property var plantIdentifierPage: Component {
        PlantIdentifier {}
    }
    property var posometrePage: Component {
        Posometre {}
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
    property var plantSearchPage: Component {
        PlantSearch {}
    }
    property var plantShortDescriptionsPage: Component {
        PlantShortDescriptions {}
    }
    property var plantFrequenciesPage: Component {
        PlantFrequencies {}
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

    property var feedPage: Component {
        Feed {}
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
