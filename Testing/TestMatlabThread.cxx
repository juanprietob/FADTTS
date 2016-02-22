#include "TestMatlabThread.h"

TestMatlabThread::TestMatlabThread()
{
}

/**********************************************************************/
/*************************** Test Functions ***************************/
/**********************************************************************/
/*************** Script ***************/
bool TestMatlabThread::Test_InitMatlabScript( QString refMatlabScriptPath )
{
    MatlabThread matlabThread;
    QString matlabOutputDir = "./path/matlabOutputDir";
    QString matlabScriptName = "./path/outputDir";
    QString expectedRefMatlabScript;
    QFile file( refMatlabScriptPath );
    file.open( QIODevice::ReadOnly );
    QTextStream ts( &file );
    expectedRefMatlabScript = ts.readAll();
    file.close();


    matlabThread.InitMatlabScript( matlabOutputDir, matlabScriptName );

    bool testMatlabOutputDir = matlabThread.m_outputDir == matlabOutputDir;
    bool testMatlabScriptName = matlabThread.m_matlabScriptName == matlabScriptName;
    bool testGetMatlabScript = expectedRefMatlabScript == matlabThread.m_matlabScript;


    bool testInitMatlabScript_Passed = testMatlabOutputDir && testMatlabScriptName && testGetMatlabScript;
    if( !testInitMatlabScript_Passed )
    {
        std::cerr << "/!\\ Test_InitMatlabScript() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with InitMatlabScript( QString matlabOutputDir, QString matlabScriptName )" << std::endl;
        if( !testMatlabOutputDir )
        {
            std::cerr << "\t+ m_matlabOutputDir is not set correctly" << std::endl;
        }
        if( !testMatlabScriptName )
        {
            std::cerr << "\t+ m_matlabScriptName is not set correctly" << std::endl;
        }
        if( !testGetMatlabScript )
        {
            std::cerr << "\t+ m_matlabScript is not initialized correctly" << std::endl;
        }
        std::cerr << "/!\\ WARNING /!\\" << std::endl;
        std::cerr << "/!\\ WARNING /!\\ As many Matlab script generation heavly rely on InitMatlabScript( QString matlabOutputDir, QString matlabScriptName )," << std::endl;
        std::cerr << "/!\\ WARNING /!\\ Matlab scripts generated by FADTTSter should be considered useless as long as Test_InitMatlabScript() remains failed" << std::endl;
        std::cerr << "/!\\ WARNING /!\\" << std::endl;
    }
    else
    {
        std::cerr << "Test_InitMatlabScript() PASSED" << std::endl;
    }

    return testInitMatlabScript_Passed;
}


bool TestMatlabThread::Test_SetHeader()
{
    MatlabThread matlabThread;
    QString expectedVersion = QString( FADTTS_VERSION ).prepend( "V" );
    QString expectedDate = QDate::currentDate().toString( "MM/dd/yyyy" );
    QString expectedTime = QTime::currentTime().toString( "hh:mm ap" );
    QString version;
    QString date;
    QString time;


    matlabThread.m_matlabScript = "$version$";
    matlabThread.SetHeader();
    version = matlabThread.m_matlabScript;
    bool testVersion = version == expectedVersion;

    matlabThread.m_matlabScript = "$date$";
    matlabThread.SetHeader();
    date = matlabThread.m_matlabScript;
    bool testDate = date == expectedDate;

    matlabThread.m_matlabScript = "$time$";
    matlabThread.SetHeader();
    time = matlabThread.m_matlabScript;
    bool testTime = time == expectedTime;


    bool testSetHeader_Passed = testVersion && testDate && testTime;
    if( !testSetHeader_Passed )
    {
        std::cerr << "/!\\ Test_SetHeader() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetHeader()" << std::endl;
        if( !testVersion )
        {
            std::cerr << "\t   expected version: " << expectedVersion.toStdString() << " | version set: " << version.toStdString() << std::endl;
        }
        if( !testDate )
        {
            std::cerr << "\t   expected date: " << expectedDate.toStdString() << " | date set: " << date.toStdString() << std::endl;
        }
        if( !testTime )
        {
            std::cerr << "\t   expected time: " << expectedTime.toStdString() << " | time set: " << time.toStdString() << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_SetHeader() PASSED" << std::endl;
    }

    return testSetHeader_Passed;
}


bool TestMatlabThread::Test_SetNbrCompThreads()
{
    MatlabThread matlabThread;
    int nbrComp = 5;
    QString expectedNbrCompThreadsString1 = "maxNumCompThreads( " + QString::number( nbrComp ) + " );";
    QString expectedNbrCompThreadsString2 = "% Option ignored";
    QString nbrCompThreadsString1;
    QString nbrCompThreadsString2;


    matlabThread.m_matlabScript = "$nbrCompThreads$";
    matlabThread.SetNbrCompThreads( true, nbrComp );
    nbrCompThreadsString1 = matlabThread.m_matlabScript;
    bool testnbrCompThreadsString1 = nbrCompThreadsString1 == expectedNbrCompThreadsString1;

    matlabThread.m_matlabScript = "$nbrCompThreads$";
    matlabThread.SetNbrCompThreads( false, nbrComp );
    nbrCompThreadsString2 = matlabThread.m_matlabScript;
    bool testnbrCompThreadsString2 = nbrCompThreadsString2 == expectedNbrCompThreadsString2;


    bool testSetNbrCompThread_Passed = testnbrCompThreadsString1 && testnbrCompThreadsString2;
    if( !testSetNbrCompThread_Passed )
    {
        std::cerr << "/!\\ Test_SetNbrCompThreads() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetNbrCompThreads( bool isRunOnSystem, int nbrComp )" << std::endl;
        if( !testnbrCompThreadsString1 )
        {
            std::cerr << "\t+ When Matlab is run on the system:" << std::endl;
            std::cerr << "\t   expected string: " << expectedNbrCompThreadsString1.toStdString() << " | string set: " << nbrCompThreadsString1.toStdString() << std::endl;
        }
        if( !testnbrCompThreadsString2 )
        {
            std::cerr << "\t+ When Matlab is not run on the system:" << std::endl;
            std::cerr << "\t   expected string: " << expectedNbrCompThreadsString2.toStdString() << " | string set: " << nbrCompThreadsString2.toStdString() << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_SetNbrCompThreads() PASSED" << std::endl;
    }

    return testSetNbrCompThread_Passed;
}

bool TestMatlabThread::Test_SetMVCMPath()
{
    MatlabThread matlabThread;
    QString expextedMVCMPath = "./path/MVCM";
    QString mvcmPath;


    matlabThread.m_matlabScript = "$addMVCMPath$";
    matlabThread.SetMVCMPath( expextedMVCMPath );
    mvcmPath = matlabThread.m_matlabScript;


    bool testSetMVCMPath_Passed = mvcmPath == expextedMVCMPath;
    if( !testSetMVCMPath_Passed )
    {
        std::cerr << "/!\\ Test_SetMVCMPath() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetMVCMPath( QString mvcmPath )" << std::endl;
        std::cerr << "\t   expected string: " << expextedMVCMPath.toStdString() << " | string set: " << mvcmPath.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetMVCMPath() PASSED" << std::endl;
    }

    return testSetMVCMPath_Passed;
}


bool TestMatlabThread::Test_SetFiberName()
{
    MatlabThread matlabThread;
    QString fibername = "testFibername";
    QString expextedFibernameString = "fiberName = '" + fibername + "';\n";
    QString fibernameString;


    matlabThread.m_matlabScript = "$fiberName$";
    matlabThread.SetFiberName( fibername );
    fibernameString = matlabThread.m_matlabScript;


    bool testSetFiberName_Passed = fibernameString == expextedFibernameString;
    if( !testSetFiberName_Passed )
    {
        std::cerr << "/!\\ Test_SetFiberName() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetFiberName( QString fiberName )" << std::endl;
        std::cerr << "\t   expected string: " << expextedFibernameString.toStdString();
        std::cerr << "\t   string set: " << fibernameString.toStdString();
    }
    else
    {
        std::cerr << "Test_SetFiberName() PASSED" << std::endl;
    }

    return testSetFiberName_Passed;
}

bool TestMatlabThread::Test_SetDiffusionProperties()
{
    MatlabThread matlabThread;
    QStringList selectedPrefixes = QStringList() << "AD" << "FA" << "SUBMATRIX";
    QString expectedDiffusionPropertiesString;
    foreach ( QString prefID, selectedPrefixes )
    {
        expectedDiffusionPropertiesString.append( prefID.toUpper() + " = '" + prefID.toUpper() + "';\n" );
    }
    QString expectedListDiffusionPropertiesString = "Dnames = cell( " + QString::number( selectedPrefixes.size() ) + ", 1 );\n";
    int i = 1;
    foreach ( QString prefID, selectedPrefixes )
    {
        expectedListDiffusionPropertiesString.append( "Dnames{ " + QString::number( i ) + " } = " + prefID.toUpper() + ";\n" );
        i++;
    }
    QString diffusionPropertiesString;
    QString listDiffusionPropertiesString;


    matlabThread.m_matlabScript = "$diffusionProperties$";
    matlabThread.SetDiffusionProperties( selectedPrefixes );
     diffusionPropertiesString = matlabThread.m_matlabScript;
    bool testDiffusionProperties = diffusionPropertiesString == expectedDiffusionPropertiesString;

    matlabThread.m_matlabScript = "$listDiffusionProperties$";
    matlabThread.SetDiffusionProperties( selectedPrefixes );
    listDiffusionPropertiesString = matlabThread.m_matlabScript;
    bool testListDiffusionProperties = listDiffusionPropertiesString == expectedListDiffusionPropertiesString;


    bool testSetDiffusionProperties_Passed = testDiffusionProperties && testListDiffusionProperties;
    if( !testSetDiffusionProperties_Passed )
    {
        std::cerr << "/!\\ Test_SetDiffusionProperties() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetDiffusionProperties( QStringList selectedPrefixes )" << std::endl;
        if( !testDiffusionProperties )
        {
            std::cerr << "\t+ When setting $inputDiffusionProperties$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedDiffusionPropertiesString.toStdString();
            std::cerr << "\t   string set:\n" <<  diffusionPropertiesString.toStdString() << std::endl;
        }
        if( !testListDiffusionProperties )
        {
            std::cerr << "\t+ When setting $diffusionProperties$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedListDiffusionPropertiesString.toStdString();
            std::cerr << "\t   string set:\n" << listDiffusionPropertiesString.toStdString() << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_SetDiffusionProperties() PASSED" << std::endl;
    }

    return testSetDiffusionProperties_Passed;
}

bool TestMatlabThread::Test_SetInputFiles()
{
    MatlabThread matlabThread;
    QMap< int, QString > matlabInputFiles;
    matlabInputFiles.insert( 0, "./path/input_AD_File.csv" );
    matlabInputFiles.insert( 1, "./path/input_RD_File.csv" );
    matlabInputFiles.insert( 4, "./path/input_submatrix_File.csv" );
    QString expectedSubMatrixFileString = "input_submatrix_File = strcat( loadingFolder, '/input_submatrix_File.csv' );";
    QString expectedSubMatrixDataString = "data2 = dlmread( input_submatrix_File, ',', 1, 1);";
    QString expectedDiffusionFilesString
            = "input_AD_File = strcat( loadingFolder, '/input_AD_File.csv' );\n"
            "input_RD_File = strcat( loadingFolder, '/input_RD_File.csv' );\n";
    QString expectedDiffusionDataString
            =
            "diffusionFiles = cell( " + QString::number( matlabInputFiles.size() - 1 ) + ", 1 );\n"
            "dataFiber1All = dlmread( input_AD_File, ',', 1, 0 );\n"
            "diffusionFiles{ 1 } = dataFiber1All( :, 2:end );\n"
            "dataFiber2All = dlmread( input_RD_File, ',', 1, 0 );\n"
            "diffusionFiles{ 2 } = dataFiber2All( :, 2:end );\n";
    QString subMatrixFileString;
    QString subMatrixDataString;
    QString diffusionFilesString;
    QString diffusionDataString;


    matlabThread.m_matlabScript = "$subMatrixFile$";
    matlabThread.SetInputFiles( matlabInputFiles );
    subMatrixFileString = matlabThread.m_matlabScript;
    bool testSubMatrixFile = subMatrixFileString == expectedSubMatrixFileString;

    matlabThread.m_matlabScript = "$subMatrixData$";
    matlabThread.SetInputFiles( matlabInputFiles );
    subMatrixDataString = matlabThread.m_matlabScript;
    bool testSubMatrixData = subMatrixDataString == expectedSubMatrixDataString;

    matlabThread.m_matlabScript = "$diffusionFiles$";
    matlabThread.SetInputFiles( matlabInputFiles );
    diffusionFilesString = matlabThread.m_matlabScript;
    bool testDiffusionFiles = diffusionFilesString == expectedDiffusionFilesString;

    matlabThread.m_matlabScript = "$diffusionData$";
    matlabThread.SetInputFiles( matlabInputFiles );
    diffusionDataString = matlabThread.m_matlabScript;
    bool testDiffusionData = diffusionDataString == expectedDiffusionDataString;


    bool testSetInputFiles_Passed = testSubMatrixFile && testSubMatrixData && testDiffusionFiles && testDiffusionData;
    if( !testSetInputFiles_Passed )
    {
        std::cerr << "/!\\ Test_SetInputFiles() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetInputFiles( QMap< int, QString > matlabInputFiles )" << std::endl;
        if( !testSubMatrixFile )
        {
            std::cerr << "\t+ When setting $subMatrixFile$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedSubMatrixFileString.toStdString() << std::endl;
            std::cerr << "\t   string set:\n" << subMatrixFileString.toStdString() << std::endl << std::endl;
        }
        if( !testSubMatrixData )
        {
            std::cerr << "\t+ When setting $subMatrixData$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedSubMatrixDataString.toStdString() << std::endl;
            std::cerr << "\t   string set:\n" << subMatrixDataString.toStdString() << std::endl << std::endl;
        }
        if( !testDiffusionFiles )
        {
            std::cerr << "\t+ When setting $diffusionFiles$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedDiffusionFilesString.toStdString();
            std::cerr << "\t   string set:\n" << diffusionFilesString.toStdString() << std::endl;
        }
        if( !testDiffusionData )
        {
            std::cerr << "\t+ When setting $diffusionData$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedDiffusionDataString.toStdString();
            std::cerr << "\t   string set:\n" << diffusionDataString.toStdString() << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_SetInputFiles() PASSED" << std::endl;
    }

    return testSetInputFiles_Passed;
}

bool TestMatlabThread::Test_SetCovariates()
{
    MatlabThread matlabThread;
    QMap<int, QString> selectedCovariates;
    selectedCovariates.insert( -1, "Intercept" );
    selectedCovariates.insert( 0, "Gender" );
    selectedCovariates.insert( 2, "Scanner" );
    selectedCovariates.insert( 5, "Twin" );
    QString expectedNbrCovariatesString = "nbrCovariates = " + QString::number( selectedCovariates.count() ) + ";";
    QString expectedCovariatesString
            = "Intercept = 'Intercept';\n"
            "Gender = 'Gender';\n"
            "Scanner = 'Scanner';\n"
            "Twin = 'Twin';\n";
    QString expectedListCovariatesString
            = "Cnames{ 1 } = Intercept;\n"
            "Cnames{ 2 } = Gender;\n"
            "Cnames{ 3 } = Scanner;\n"
            "Cnames{ 4 } = Twin;\n";
    QString inputNbrCovariatesString;
    QString listCovariatesString;
    QString covariatesString;


    matlabThread.m_matlabScript = "$nbrCovariates$";
    matlabThread.SetCovariates( selectedCovariates );
    inputNbrCovariatesString = matlabThread.m_matlabScript;
    bool testSubMatrixFile = inputNbrCovariatesString == expectedNbrCovariatesString;

    matlabThread.m_matlabScript = "$covariates$";
    matlabThread.SetCovariates( selectedCovariates );
    listCovariatesString = matlabThread.m_matlabScript;
    bool testSubMatrixData = listCovariatesString == expectedCovariatesString;

    matlabThread.m_matlabScript = "$listCovariates$";
    matlabThread.SetCovariates( selectedCovariates );
    covariatesString = matlabThread.m_matlabScript;
    bool testDiffusionFiles = covariatesString == expectedListCovariatesString;


    bool testSetCovariates_Passed = testSubMatrixFile && testSubMatrixData && testDiffusionFiles;
    if( !testSetCovariates_Passed )
    {
        std::cerr << "/!\\ Test_SetCovariates() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetCovariates( QMap<int, QString> selectedCovariates )" << std::endl;
        if( !testSubMatrixFile )
        {
            std::cerr << "\t+ When setting $inputNbrCovariates$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedNbrCovariatesString.toStdString() << std::endl;
            std::cerr << "\t   string set:\n" << inputNbrCovariatesString.toStdString() << std::endl << std::endl;
        }
        if( !testSubMatrixData )
        {
            std::cerr << "\t+ When setting $ListCovariates$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedCovariatesString.toStdString();
            std::cerr << "\t   string set:\n" << listCovariatesString.toStdString() << std::endl;
        }
        if( !testDiffusionFiles )
        {
            std::cerr << "\t+ When setting $covariates$:" << std::endl;
            std::cerr << "\t   expected string:\n" << expectedListCovariatesString.toStdString();
            std::cerr << "\t   string set:\n" << covariatesString.toStdString() << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_SetCovariates() PASSED" << std::endl;
    }

    return testSetCovariates_Passed;
}


bool TestMatlabThread::Test_SetNbrPermutation()
{
    MatlabThread matlabThread;
    int nbrPermutations = 500;
    QString expectedNbrPermutationsString = "nbrPermutations = " + QString::number( nbrPermutations ) + ";";
    QString nbrPermutationsString;


    matlabThread.m_matlabScript = "$nbrPermutations$";
    matlabThread.SetNbrPermutation( nbrPermutations );
    nbrPermutationsString = matlabThread.m_matlabScript;


    bool testSetNbrPermutation_Passed = nbrPermutationsString == expectedNbrPermutationsString;
    if( !testSetNbrPermutation_Passed )
    {
        std::cerr << "/!\\ Test_SetNbrPermutation() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetNbrPermutation( int nbrPermutation )" << std::endl;
        std::cerr << "\t   expected string: " << expectedNbrPermutationsString.toStdString() << " | string set: " << nbrPermutationsString.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetNbrPermutation() PASSED" << std::endl;
    }

    return testSetNbrPermutation_Passed;
}

bool TestMatlabThread::Test_SetOmnibus()
{
    MatlabThread matlabThread;
    bool omnibus = false;
    QString expectedOmnibusString = "omnibus = " + QString::number( omnibus ) + ";";
    QString omnibusString;


    matlabThread.m_matlabScript = "$omnibus$";
    matlabThread.SetOmnibus( omnibus );
    omnibusString = matlabThread.m_matlabScript;


    bool testSetOmnibus_Passed = omnibusString == expectedOmnibusString;
    if( !testSetOmnibus_Passed )
    {
        std::cerr << "/!\\ Test_SetOmnibus() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetOmnibus( bool omnibus )" << std::endl;
        std::cerr << "\t   expected string: " << expectedOmnibusString.toStdString() << " | string set: " << omnibusString.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetOmnibus() PASSED" << std::endl;
    }

    return testSetOmnibus_Passed;
}

bool TestMatlabThread::Test_SetPostHoc()
{
    MatlabThread matlabThread;
    bool postHoc = false;
    QString expectedPostHocString = "postHoc = " + QString::number( postHoc ) + ";";
    QString PostHocString;


    matlabThread.m_matlabScript = "$postHoc$";
    matlabThread.SetPostHoc( postHoc );
    PostHocString = matlabThread.m_matlabScript;


    bool testSetPostHoc_Passed = PostHocString == expectedPostHocString;
    if( !testSetPostHoc_Passed )
    {
        std::cerr << "/!\\ Test_SetPostHoc() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetPostHoc( bool postHoc )" << std::endl;
        std::cerr << "\t   expected string: " << expectedPostHocString.toStdString() << " | string set: " << PostHocString.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetPostHoc() PASSED" << std::endl;
    }

    return testSetPostHoc_Passed;
}

bool TestMatlabThread::Test_SetConfidenceBandsThreshold()
{
    MatlabThread matlabThread;
    double confidenceBandsThreshold = 0.04;
    QString expectedconfidenceBandsThresholdString = "confidenceBandsThreshold = " + QString::number( confidenceBandsThreshold ) + ";";
    QString confidenceBandsThresholdString;


    matlabThread.m_matlabScript = "$confidenceBandsThreshold$";
    matlabThread.SetConfidenceBandsThreshold( confidenceBandsThreshold );
    confidenceBandsThresholdString = matlabThread.m_matlabScript;


    bool testSetConfidenceBandsThreshold_Passed = confidenceBandsThresholdString == expectedconfidenceBandsThresholdString;
    if( !testSetConfidenceBandsThreshold_Passed )
    {
        std::cerr << "/!\\ Test_SetConfidenceBandsThreshold() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetConfidenceBandsThreshold( double confidenceBandsThreshold )" << std::endl;
        std::cerr << "\t   expected string: " << expectedconfidenceBandsThresholdString.toStdString() << " | string set: " << confidenceBandsThresholdString.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetConfidenceBandsThreshold() PASSED" << std::endl;
    }

    return testSetConfidenceBandsThreshold_Passed;
}

bool TestMatlabThread::Test_SetPvalueThreshold()
{
    MatlabThread matlabThread;
    double pvalueThreshold = 0.04;
    QString expectedPvalueThresholdString = "pvalueThreshold = " + QString::number( pvalueThreshold ) + ";";
    QString pvalueThresholdString;


    matlabThread.m_matlabScript = "$pvalueThreshold$";
    matlabThread.SetPvalueThreshold( pvalueThreshold );
    pvalueThresholdString = matlabThread.m_matlabScript;


    bool testSetSetPvalueThreshold_Passed = pvalueThresholdString == expectedPvalueThresholdString;
    if( !testSetSetPvalueThreshold_Passed )
    {
        std::cerr << "/!\\ Test_SetPvalueThreshold() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with SetPvalueThreshold( double pvalueThreshold )" << std::endl;
        std::cerr << "\t   expected string: " << expectedPvalueThresholdString.toStdString() << " | string set: " << pvalueThresholdString.toStdString() << std::endl;
    }
    else
    {
        std::cerr << "Test_SetPvalueThreshold() PASSED" << std::endl;
    }

    return testSetSetPvalueThreshold_Passed;
}


bool TestMatlabThread::Test_GenerateMFiles( QString myFDR, QString outputDir )
{
    MatlabThread matlabThread;
    matlabThread.InitMatlabScript( outputDir, "TestMFileGeneration.m" );
    QString expectedMyFDRData;
    QFile expectedMyFDRFile( myFDR );
    expectedMyFDRFile.open( QIODevice::ReadOnly );
    QTextStream tsExpectedMyFDR( &expectedMyFDRFile );
    expectedMyFDRData = tsExpectedMyFDR.readAll();
    expectedMyFDRFile.close();


    matlabThread.GenerateMatlabFiles();

    bool testMatlabOutputDir = QDir( outputDir + "/MatlabOutputs" ).exists();
    bool testMatlabScript = QFile( outputDir + "/TestMFileGeneration.m" ).exists();

    QString myFDRData;
    QFile myFDRFile( matlabThread.m_outputDir + "/myFDR.m" );
    myFDRFile.open( QIODevice::ReadOnly );
    QTextStream tsMyFDR( &myFDRFile );
    myFDRData = tsMyFDR.readAll();
    myFDRFile.close();

    bool testMyFDRFile = QFile( myFDRFile.fileName() ).exists();
    bool testMyFDRData = myFDRData == expectedMyFDRData;


    bool testGenerateMFiles_Passed = testMatlabOutputDir && testMatlabScript && testMyFDRFile && testMyFDRData;
    if( !testGenerateMFiles_Passed )
    {
        std::cerr << "/!\\ Test_GenerateMFiles() FAILED /!\\" << std::endl;
        std::cerr << "\t+ pb with GenerateMatlabFiles() and/or GenerateMyFDR()" << std::endl;
        if( !testMatlabOutputDir )
        {
            std::cerr << "\t+ Matlab output directory not created" << std::endl;
        }
        if( !testMatlabScript )
        {
            std::cerr << "\t+ Matlab script not generated" << std::endl;
        }
        if( !testMyFDRFile )
        {
            std::cerr << "\t+ myFDR script not generated" << std::endl;
        }
        if( !testMyFDRData )
        {
            std::cerr << "\t+ myFDR script data incorrect" << std::endl;
        }
    }
    else
    {
        std::cerr << "Test_GenerateMFiles() PASSED" << std::endl;
    }

    return testGenerateMFiles_Passed;
}


/**********************************************************************/
/********************** Functions Used For Testing ********************/
/**********************************************************************/
QByteArray TestMatlabThread::GetHashFile( QString filePath )
{
    QCryptographicHash hash( QCryptographicHash::Sha1 );
    QFile file( filePath );

    if( file.open( QIODevice::ReadOnly ) )
    {
        hash.addData( file.readAll() );
        file.close();
    }
    else
    {
        std::cerr << "Cannot open file: " << filePath.toStdString() << std::endl;
    }

    return hash.result().toHex();
}

bool TestMatlabThread::CompareFile( QString filePath1, QString filePath2 )
{
    QByteArray sig1 = GetHashFile( filePath1 );
    QByteArray sig2 = GetHashFile( filePath2 );

    if( sig1 == sig2 )
    {
        return true;
    }
    else
    {
        return false;
    }
}
