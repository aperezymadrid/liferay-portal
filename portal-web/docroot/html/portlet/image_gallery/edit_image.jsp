<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/image_gallery/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

String referringPortletResource = ParamUtil.getString(request, "referringPortletResource");

String uploadProgressId = "igImageUploadProgress";

IGImage image = (IGImage)request.getAttribute(WebKeys.IMAGE_GALLERY_IMAGE);

long imageId = BeanParamUtil.getLong(image, request, "imageId");

long folderId = BeanParamUtil.getLong(image, request, "folderId");
String name = BeanParamUtil.getString(image, request, "name");

String extension = StringPool.BLANK;

if (image != null) {
	extension = StringPool.PERIOD + image.getImageType();
}

String assetTagNames = ParamUtil.getString(request, "assetTagNames");

IGFolder folder = null;
Image largeImage = null;

if (image != null) {
	folder = image.getFolder();
	largeImage = ImageLocalServiceUtil.getImage(image.getLargeImageId());
}
%>

<c:if test="<%= image == null %>">
	<aui:script use="liferay-upload">
		new Liferay.Upload(
			{
				allowedFileTypes: '<%= StringUtil.merge(PrefsPropsUtil.getStringArray(PropsKeys.IG_IMAGE_EXTENSIONS, StringPool.COMMA)) %>',
				container: '#<portlet:namespace />fileUpload',
				fileDescription: '<%= StringUtil.merge(PrefsPropsUtil.getStringArray(PropsKeys.IG_IMAGE_EXTENSIONS, StringPool.COMMA)) %>',
				fallbackContainer: '#<portlet:namespace />fallback',
				maxFileSize: <%= PrefsPropsUtil.getLong(PropsKeys.IG_IMAGE_MAX_SIZE) %> / 1024,
				namespace: '<portlet:namespace />',
				uploadFile: '<liferay-portlet:actionURL windowState="<%= LiferayWindowState.POP_UP.toString() %>" doAsUserId="<%= user.getUserId() %>"><portlet:param name="struts_action" value="/image_gallery/edit_image" /><portlet:param name="<%= Constants.CMD %>" value="<%= Constants.ADD %>" /><portlet:param name="folderId" value="<%= String.valueOf(folderId) %>" /></liferay-portlet:actionURL><liferay-ui:input-permissions-params modelName="<%= IGImage.class.getName() %>" />'
			}
		);
	</aui:script>

	<div class="lfr-dynamic-uploader">
		<div class="lfr-upload-container" id="<portlet:namespace />fileUpload"></div>
	</div>

	<div class="lfr-fallback aui-helper-hidden" id="<portlet:namespace />fallback">
</c:if>

<aui:script>
	function <portlet:namespace />removeFolder() {
		document.<portlet:namespace />fm.<portlet:namespace />folderId.value = "<%= rootFolderId %>";

		var nameEl = document.getElementById("<portlet:namespace />folderName");

		nameEl.href = "";
		nameEl.innerHTML = "";
	}

	function <portlet:namespace />saveImage() {
		<%= HtmlUtil.escape(uploadProgressId) %>.startProgress();

		document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "<%= image == null ? Constants.ADD : Constants.UPDATE %>";
		submitForm(document.<portlet:namespace />fm);
	}

	function <portlet:namespace />selectFolder(folderId, folderName) {
		document.<portlet:namespace />fm.<portlet:namespace />folderId.value = folderId;

		var nameEl = document.getElementById("<portlet:namespace />folderName");

		nameEl.href = "<portlet:renderURL windowState="<%= WindowState.MAXIMIZED.toString() %>"><portlet:param name="struts_action" value="/image_gallery/view" /></portlet:renderURL>&<portlet:namespace />folderId=" + folderId;
		nameEl.innerHTML = folderName + "&nbsp;";
	}
</aui:script>

<liferay-util:include page="/html/portlet/image_gallery/top_links.jsp" />

<portlet:actionURL var="editImageURL">
	<portlet:param name="struts_action" value="/image_gallery/edit_image" />
</portlet:actionURL>

<aui:form action="<%= editImageURL %>" enctype="multipart/form-data" method="post" name="fm" onSubmit='<%= renderResponse.getNamespace() + "saveImage(); return false;" %>'>
	<aui:input name="<%= Constants.CMD %>" type="hidden" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:input name="referringPortletResource" type="hidden" value="<%= referringPortletResource %>" />
	<aui:input name="uploadProgressId" type="hidden" value="<%= uploadProgressId %>" />
	<aui:input name="imageId" type="hidden" value="<%= imageId %>" />
	<aui:input name="folderId" type="hidden" value="<%= folderId %>" />

	<c:if test="<%= image != null %>">
		<h3 class="image-title"><%= image.getName() %></h3>
	</c:if>

	<liferay-ui:error exception="<%= DuplicateImageNameException.class %>" message="please-enter-a-unique-image-name" />

	<liferay-ui:error exception="<%= ImageNameException.class %>">
		<liferay-ui:message key="image-names-must-end-with-one-of-the-following-extensions" /> <%= StringUtil.merge(PrefsPropsUtil.getStringArray(PropsKeys.IG_IMAGE_EXTENSIONS, StringPool.COMMA), StringPool.COMMA_AND_SPACE) %>.
	</liferay-ui:error>

	<liferay-ui:error exception="<%= ImageSizeException.class %>" message="please-enter-a-file-with-a-valid-file-size" />
	<liferay-ui:error exception="<%= NoSuchFolderException.class %>" message="please-enter-a-valid-folder" />

	<liferay-ui:asset-tags-error />

	<aui:model-context bean="<%= image %>" model="<%= IGImage.class %>" />

	<aui:field-wrapper>

		<%
		long imageMaxSize = PrefsPropsUtil.getLong(PropsKeys.IG_IMAGE_MAX_SIZE) / 1024;
		%>

		<c:if test="<%= imageMaxSize != 0 %>">
			<div class="portlet-msg-info">
				<%= LanguageUtil.format(pageContext, "upload-images-no-larger-than-x-k", String.valueOf(imageMaxSize), false) %>
			</div>
		</c:if>
	</aui:field-wrapper>

	<aui:fieldset>
		<c:if test="<%= ((image != null) || (folderId <= 0)) %>">
			<aui:field-wrapper label="folder">
					<%
					String folderName = StringPool.BLANK;

					if (folderId > 0) {
						folder = IGFolderLocalServiceUtil.getFolder(folderId);

						folder = folder.toEscapedModel();

						folderId = folder.getFolderId();
						folderName = folder.getName();
					}
					%>

					<portlet:renderURL windowState="<%= WindowState.MAXIMIZED.toString() %>" var="viewFolderURL">
						<portlet:param name="struts_action" value="/image_gallery/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(folderId) %>" />
					</portlet:renderURL>

					<aui:a href="<%= viewFolderURL %>" id="folderName"><%= folderName %></aui:a>

					<portlet:renderURL windowState="<%= LiferayWindowState.POP_UP.toString() %>" var="selectFolderURL">
						<portlet:param name="struts_action" value="/image_gallery/select_folder" />
						<portlet:param name="folderId" value="<%= String.valueOf(folderId) %>" />
					</portlet:renderURL>

					<%
					String taglibOpenFolderWindow = "var folderWindow = window.open('" + selectFolderURL + "','folder', 'directories=no,height=640,location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,width=680'); void(''); folderWindow.focus();";
					%>

					<aui:button onClick="<%= taglibOpenFolderWindow %>" value="select" />

					<aui:button name="removeFolderButton" onClick='<%= renderResponse.getNamespace() + "removeFolder();" %>' value="remove" />
			</aui:field-wrapper>
		</c:if>

		<aui:input name="file" type="file" />

		<aui:input name="name" />

		<aui:input name="description" />

		<liferay-ui:custom-attributes-available className="<%= IGImage.class.getName() %>">
			<liferay-ui:custom-attribute-list
				className="<%= IGImage.class.getName() %>"
				classPK="<%= imageId %>"
				editable="<%= true %>"
				label="<%= true %>"
			/>
		</liferay-ui:custom-attributes-available>

		<aui:input name="categories" type="assetCategories" />

		<aui:input name="tags" type="assetTags" />

		<c:if test="<%= image == null %>">
			<aui:field-wrapper label="permissions">
				<liferay-ui:input-permissions
					modelName="<%= IGImage.class.getName() %>"
				/>
			</aui:field-wrapper>
		</c:if>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" />

		<aui:button onClick="<%= redirect %>" type="cancel" />
	</aui:button-row>
</aui:form>

<aui:script>
	<c:if test="<%= windowState.equals(WindowState.MAXIMIZED) %>">
		Liferay.Util.focusFormField(document.<portlet:namespace />fm.<portlet:namespace />file);
	</c:if>
</aui:script>

<aui:script use="event,node">
	var validateFile = function(fileField) {
		var value = fileField.val();

		if (value) {
			var extension = value.substring(value.lastIndexOf('.')).toLowerCase();
			var validExtensions = ['<%= StringUtil.merge(PrefsPropsUtil.getStringArray(PropsKeys.IG_IMAGE_EXTENSIONS, StringPool.COMMA), "', '") %>'];

			if ((A.Array.indexOf(validExtensions, '*') == -1) &&
				(A.Array.indexOf(validExtensions, extension) == -1)) {

				alert('<%= UnicodeLanguageUtil.get(pageContext, "image-names-must-end-with-one-of-the-following-extensions") %> <%= StringUtil.merge(PrefsPropsUtil.getStringArray(PropsKeys.IG_IMAGE_EXTENSIONS, StringPool.COMMA), StringPool.COMMA_AND_SPACE) %>');

				fileField.val('');
			}
		}
	};

	var onFileChange = function(event) {
		validateFile(event.currentTarget);
	};

	var fileField = A.one('#<portlet:namespace />file')

	if (fileField) {
		fileField.on('change', onFileChange);

		validateFile(fileField);
	}
</aui:script>

<liferay-ui:upload-progress
	id="<%= uploadProgressId %>"
	message="uploading"
	redirect="<%= redirect %>"
/>

<c:if test="<%= image == null %>">
	</div>
</c:if>

<%
if (image != null) {
	IGUtil.addPortletBreadcrumbEntries(image, request, renderResponse);

	PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, "edit"), currentURL);
}
else {
	IGUtil.addPortletBreadcrumbEntries(folderId, request, renderResponse);

	PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, "add-image"), currentURL);
}
%>